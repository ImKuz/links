import Combine
import Models
import XCTest
import ToolKit
import Contracts

@testable import CatalogClient
@testable import GRPC
import XCTestDynamicOverlay

final class CatalogItemsProviderTests: XCTestCase {

    enum Spec {
        static let host = "foo"
        static let port = 1
    }

    var provider: CatalogItemsProviderImpl!
    var sourceClient: Catalog_SourceTestClient!
    var stream: FakeStreamingResponse<Catalog_Empty, Catalog_Catalog>?

    private var cancellables = [AnyCancellable]()

    override func setUp() {
        let source = Catalog_SourceTestClient()
        let factory = CatalogSourceClientFactoryFake(source: source)
        sourceClient = source
        provider = .init(catalogSourceClientFactory: factory)
    }

    func test_fetch() {
        let exp = expectation(description: "exp")
        let stub = catalogStub()

        provider.configure(host: Spec.host, port: Spec.port)
        stream = sourceClient.makefetchResponseStream()

        provider
            .subscribe()
            .sink(
                receiveCompletion: { _ in
                    fatalError("Unexpected")
                },
                receiveValue: { items in
                    XCTAssertEqual(items.count, stub.items.count)
                    XCTAssertEqual(items.first?.id, stub.items.first?.snippet.id)
                    exp.fulfill()
                }
            )
            .store(in: &cancellables)


        stream?.activate()
        try! stream?.sendMessage(stub)

        wait(for: [exp], timeout: 1)
    }

    func test_commonError() {
        let exp = expectation(description: "exp")

        provider.configure(host: Spec.host, port: Spec.port)
        stream = sourceClient.makefetchResponseStream()

        let fakeError = NSError(
            domain: "foo",
            code: CocoaError.fileNoSuchFile.rawValue,
            userInfo: nil
        )

        subscribeAndWaitForError {
            XCTAssertEqual($0.description, Strings.commonError)
            exp.fulfill()
        }

        stream?.activate()
        try! stream?.sendError(fakeError)

        wait(for: [exp], timeout: 0.1)
    }

    func test_cancelledStatus() {
        let exp = expectation(description: "exp")

        provider.configure(host: Spec.host, port: Spec.port)
        stream = sourceClient.makefetchResponseStream()

        subscribeAndWaitForError {
            XCTAssertEqual($0.description, Strings.cancelled)
            exp.fulfill()
        }

        stream?.activate()
        try! stream?.sendError(GRPCStatus.init(code: .cancelled, message: nil))

        wait(for: [exp], timeout: 0.1)
    }

    func test_internalErrorStatus() {
        let exp = expectation(description: "exp")

        provider.configure(host: Spec.host, port: Spec.port)
        stream = sourceClient.makefetchResponseStream()

        subscribeAndWaitForError {
            XCTAssertEqual($0.description, Strings.internalError)
            exp.fulfill()
        }

        stream?.activate()
        try! stream?.sendError(GRPCStatus.processingError)

        wait(for: [exp], timeout: 0.1)
    }

    // MARK: - Helpers

    private func subscribeAndWaitForError(completion: @escaping (AppError) -> ()) {
        provider
            .subscribe()
            .sink(
                receiveCompletion: {
                    if case let .failure(error) = $0 {
                        completion(error)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

    private func catalogStub() -> Catalog_Catalog {
        .with {
            $0.items = [
                .with {
                    $0.kind = .snippet(
                        .with {
                            $0.content = "Foo"
                            $0.id = "ID"
                            $0.name = "Bar"
                        }
                    )
                }
            ]
        }
    }
}

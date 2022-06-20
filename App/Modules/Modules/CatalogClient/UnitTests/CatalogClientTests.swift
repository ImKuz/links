import Combine
import Models
import XCTest

@testable import CatalogClient

final class CatalogClientTests: XCTestCase {

    enum Spec {
        static let port = 1
        static let host = "foo"
    }

    var provider: CatalogItemsProviderFake!
    var client: CatalogClientImpl!

    var cancellables = [AnyCancellable]()

    override func setUp() {
        provider = .init()
        cancellables = []
        client = .init(
            provider: provider,
            host: Spec.host,
            port: Spec.port
        )
    }

    func test_disconnectOnDeinit() {
        client = nil
        XCTAssertTrue(provider.isDisconnected)
    }

    func test_configurationProvidedOnSubscribe() {
        _ = client.subscribe()
        XCTAssertEqual(provider.host, Spec.host)
        XCTAssertEqual(provider.port, Spec.port)
    }

    func test_itemsSubscription() {
        let exp = expectation(description: "fetch")

        var fetchedItems = [CatalogItem]()
        let testItems = [CatalogItem(id: "foo", name: nil, content: .text("foo"))]

        client
            .subscribe()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    fetchedItems = $0
                    exp.fulfill()
                }
            )
            .store(in: &cancellables)

        provider.itemsSubject.send(testItems)

        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(fetchedItems, testItems)
    }

    func test_conectivity() {
        let exp = expectation(description: "state")
        var state: ConnectionState?

        client
            .connectivityPublisher
            .sink {
                state = $0
                exp.fulfill()
            }
            .store(in: &cancellables)


        provider.connectivitySubject.send(.ok)

        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(state, .ok)
    }
}

import GRPC
import NIO
import Combine
import Contracts
import Models
import ToolKit
import Foundation

protocol CatalogItemsProvider {

    func configure(host: String, port: Int)
    func disconnect()
    func subscribe() -> AnyPublisher<[CatalogItem], Error>
}

final class CatalogItemsProviderImpl: CatalogItemsProvider {

    private var client: Catalog_SourceClientProtocol?
    private var clientConnection: ClientConnection?
    private var itemsSubject = PassthroughSubject<[CatalogItem], Error>()
    private var call: ServerStreamingCall<Catalog_Empty, Catalog_Catalog>?
    private var cancellables = [AnyCancellable]()

    func configure(host: String, port: Int) {
        guard clientConnection == nil else { return }

        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)

        let channel = ClientConnection
            .insecure(group: group)
            .withKeepalive(
                .init(
                    interval: .seconds(120),
                    timeout: .seconds(60),
                    permitWithoutCalls: true
                )
            )
            .connect(host: host, port: port)

        clientConnection = channel
        client = Catalog_SourceClient(channel: channel)
    }

    func disconnect() {
        _ = clientConnection?.close()
    }

    func subscribe() -> AnyPublisher<[CatalogItem], Error> {
        guard let client = client else {
            return Fail(error: AppError.common(description: "Client is not configured")).eraseToAnyPublisher()
        }

        call = client.fetch(.init(), callOptions: .none) { [weak self] catalog in
            let items = Self.mapCatalog(catalog)
            self?.itemsSubject.send(items)
        }

        call?.status.whenFailure { [weak self] in
            self?.itemsSubject.send(completion: .failure($0))
        }

        return itemsSubject
            .share()
            .eraseToAnyPublisher()
    }

    private static func mapCatalog(_ catalog: Catalog_Catalog) -> [CatalogItem] {
        catalog.items.compactMap { item in
            switch item.kind {
            case .group:
                return .none
            case let .link(link):
                guard let url = URL(string: link.link) else { return .none }
                return .init(
                    id: link.id,
                    name: link.name,
                    content: .link(url)
                )
            case let .snippet(snippet):
                return .init(
                    id: snippet.id,
                    name: snippet.name,
                    content: .text(snippet.content)
                )
            case .none:
                return .none
            }
        }
    }
}

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
    func fetch() -> AnyPublisher<[CatalogItem], Error>
}

final class CatalogItemsProviderImpl: CatalogItemsProvider {

    private var client: Catalog_SourceClientProtocol?
    private var clientConnection: ClientConnection?

    func configure(host: String, port: Int) {
        guard clientConnection == nil else { return }

        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)

        let channel = ClientConnection
            .insecure(group: group)
            .connect(host: host, port: port)

        clientConnection = channel
        client = Catalog_SourceClient(channel: channel)
    }

    func disconnect() {
        _ = clientConnection?.close()
    }

    func fetch() -> AnyPublisher<[CatalogItem], Error> {
        guard let client = client else {
            return Fail(error: AppError.common(description: "Client is not configured")).eraseToAnyPublisher()
        }

        return Deferred {
            Future { [client] promise in
                let call = client.fetch(.init(), callOptions: .none)

                call.response.whenFailure {
                    promise(.failure($0))
                }

                call.response.whenSuccess { catalog in
                    let items = Self.mapCatalog(catalog)
                    promise(.success(items))
                }
            }.eraseToAnyPublisher()
        }.eraseToAnyPublisher()
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

import Combine
import ToolKit
import GRPC
import NIO
import Contracts
import Models
import Database
import Foundation
import IPAddressProvider

public protocol CatalogServer: AnyObject {

    func start(port: Int) -> AnyPublisher<(String, Int)?, AppError>
    func stop() -> AnyPublisher<Void, AppError>
}

final class CatalogServerImpl {

    private let database: DatabaseService
    private let ipAddressProvider: IPAddressProvider

    private var server: EventLoopFuture<Server>?
    private var group: MultiThreadedEventLoopGroup?
    private let contentUpdateSubject = PassthroughSubject<Void, Never>()

    init(
        database: DatabaseService,
        ipAddressProvider: IPAddressProvider
    ) {
        self.database = database
        self.ipAddressProvider = ipAddressProvider
    }
}

// MARK: - CatalogServer

extension CatalogServerImpl: CatalogServer {

    func start(port: Int) -> AnyPublisher<(String, Int)?, AppError> {
        Deferred {
            Future<(String, Int)?, AppError> { [weak self] promise in
                guard let strongSelf = self else { return }
                let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
                let provider = CatalogSourceProvider(
                    updateEventsPublisher: strongSelf.database.contentUpdatePublisher
                )
                
                provider.delegate = strongSelf

                let server = Server
                    .insecure(group: group)
                    .withServiceProviders([provider])
                    .withKeepalive(
                        .init(
                            interval: .seconds(120),
                            timeout: .seconds(60),
                            permitWithoutCalls: true
                        )
                    )
                    .bind(host: "0.0.0.0", port: port)

                server.whenFailure { error in
                    promise(.failure(.common(description: "Unable to start server")))
                }

                server
                    .map { $0.channel.localAddress }
                    .whenSuccess { address in
                        if let port = address?.port {
                            let ipAddress = self?.ipAddressProvider.ipAddress() ?? "???"
                            promise(.success((ipAddress, port)))
                        }
                }

                strongSelf.server = server
                strongSelf.group = group
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func stop() -> AnyPublisher<Void, AppError> {
        Deferred {
            Future<Void, AppError> { [weak self] promise in
                do {
                    try self?.group?.syncShutdownGracefully()
                    try self?.server?.eventLoop.close()
                    promise(.success(()))
                } catch {
                    promise(.failure(.common(description: "Unable to stop server")))
                }
            } .eraseToAnyPublisher()
        } .eraseToAnyPublisher()
    }
}

// MARK: - CatalogSourceProviderDelegate

extension CatalogServerImpl: CatalogSourceProviderDelegate {

    func providerRequestsData() -> AnyPublisher<[Models.CatalogItem], AppError> {
        Future<[Models.CatalogItem], AppError> { [weak self] promise in
            guard let self = self else { return }

            let request = FetchRequest(
                sortDescriptor: .init(key: "index", ascending: true)
            )

            self.database.fetchAsync(Database.CatalogItem.self, request: request) {
                switch $0 {
                case let .success(items):
                    let mappedItems = items.map { $0.convertToModel() }
                    promise(.success(mappedItems))
                case .failure:
                    promise(.failure(.common(description: "Unable to fetch items from database")))
                }
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: - Mapping

private extension Database.CatalogItem {

    func convertToModel() -> Models.CatalogItem {
        let itemContent: CatalogItemContent

        switch contentType {
        case "link":
            if let url = URL(string: content) {
                itemContent = .link(url)
            } else {
                itemContent = .text(content)
            }
        case "text":
            itemContent = .text(content)
        default:
            fatalError("Unsupported content type!")
        }

        return .init(
            id: itemId,
            name: name,
            content: itemContent
        )
    }
}

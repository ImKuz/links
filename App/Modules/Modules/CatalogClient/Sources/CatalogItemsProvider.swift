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
    func subscribe() -> AnyPublisher<[CatalogItem], AppError>
}

final class CatalogItemsProviderImpl: CatalogItemsProvider {

    private var client: Catalog_SourceClientProtocol?
    private var clientConnection: ClientConnection?
    private var itemsSubject = PassthroughSubject<[CatalogItem], AppError>()
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

    func subscribe() -> AnyPublisher<[CatalogItem], AppError> {
        guard let client = client else {
            return Fail(error: AppError.common(description: "Client is not configured")).eraseToAnyPublisher()
        }

        call = client.fetch(.init(), callOptions: .none) { [weak self] catalog in
            let items = Self.mapCatalog(catalog)
            self?.itemsSubject.send(items)
        }

        call?.status.whenComplete { [weak self] in
            switch $0 {
            case .failure(let error):
                let mappedError = Self.mapError(error)
                self?.itemsSubject.send(completion: .failure(mappedError))
            case .success(let status):
                let mappedError = Self.mapError(status)
                self?.itemsSubject.send(completion: .failure(mappedError))
            }
        }

        call?.status.whenFailure { [weak self] in
            let mappedError = Self.mapError($0)
            self?.itemsSubject.send(completion: .failure(mappedError))
        }

        return itemsSubject
            .share()
            .eraseToAnyPublisher()
    }

    private static func mapError(_ error: Error) -> AppError {
        if let status = error as? GRPCStatus {
            return mapGRPCStatus(status)
        } else if let error = error as? AppError {
            return error
        } else {
            return .common(description: "Something went wrong")
        }
    }

    private static func mapGRPCStatus(_ status: GRPCStatus) -> AppError {
        switch status.code {
        case .internalError:
            return .businessLogic("Server internal error has occured")
        case .cancelled:
            return .businessLogic("Connection has been cancelled")
        case .aborted:
            return .businessLogic("Connection has been aborted")
        case .unavailable:
            return .businessLogic("Server is not avaliable")
        default:
            return .businessLogic("Something went wrong")
        }
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

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
    func connectivity() -> AnyPublisher<ConnectionState, Never>
}

final class CatalogItemsProviderImpl: CatalogItemsProvider, ConnectivityStateDelegate {

    private let catalogSourceClientFactory: CatalogSourceClientFactory

    private var client: Catalog_SourceClientProtocol?
    private var itemsSubject = PassthroughSubject<[CatalogItem], AppError>()
    private var connectivitySubject = PassthroughSubject<ConnectionState, Never>()
    private var call: ServerStreamingCall<Catalog_Empty, Catalog_Catalog>?
    private var cancellables = [AnyCancellable]()

    // MARK: - Init

    init(catalogSourceClientFactory: CatalogSourceClientFactory) {
        self.catalogSourceClientFactory = catalogSourceClientFactory
    }

    // MARK: - CatalogItemsProvider

    func configure(host: String, port: Int) {
        guard client == nil else { return }

        client = catalogSourceClientFactory.make(
            host: host,
            port: port,
            connectivityStateDelegate: self
        )
    }

    func disconnect() {
        _ = client?.channel.close()
    }

    func subscribe() -> AnyPublisher<[CatalogItem], AppError> {
        guard let client = client else {
            return Fail(error: AppError.common(description: Strings.clientIsNotConfigured)).eraseToAnyPublisher()
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

    func connectivity() -> AnyPublisher<ConnectionState, Never> {
        connectivitySubject
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    // MARK: - ConnectivityStateDelegate

    func connectivityStateDidChange(
        from oldState: ConnectivityState,
        to newState: ConnectivityState
    ) {
        switch newState {
        case .idle, .ready:
            connectivitySubject.send(.ok)
        case .connecting:
            connectivitySubject.send(.connecting)
        case .transientFailure:
            connectivitySubject.send(.failure)
        case .shutdown:
            return
        }
    }

    // MARK: - Private methods

    private static func mapError(_ error: Error) -> AppError {
        if let status = error as? GRPCStatus {
            return mapGRPCStatus(status)
        } else if let error = error as? AppError {
            return error
        } else {
            return .common(description: Strings.commonError)
        }
    }

    private static func mapGRPCStatus(_ status: GRPCStatus) -> AppError {
        switch status.code {
        case .internalError:
            return .businessLogic(Strings.internalError)
        case .cancelled:
            return .businessLogic(Strings.cancelled)
        case .aborted:
            return .businessLogic(Strings.aborted)
        case .unavailable:
            return .businessLogic(Strings.unavailable)
        default:
            return .businessLogic(Strings.commonError)
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

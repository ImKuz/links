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
    func subscribe() -> AnyPublisher<[LinkItem], AppError>
    func connectivity() -> AnyPublisher<ConnectionState, Never>
}

final class CatalogItemsProviderImpl: CatalogItemsProvider, ConnectivityStateDelegate {

    private let catalogSourceClientFactory: CatalogSourceClientFactory
    private let localCatalogFavoritesProvider: LocalCatalogFavoritesProvider

    private var client: Catalog_SourceClientProtocol?
    private var itemsSubject = PassthroughSubject<[LinkItem], AppError>()
    private var connectivitySubject = PassthroughSubject<ConnectionState, Never>()
    private var call: ServerStreamingCall<Catalog_Empty, Catalog_LinkItemsList>?
    private var cancellables = [AnyCancellable]()

    // MARK: - Init

    init(
        catalogSourceClientFactory: CatalogSourceClientFactory,
        localCatalogFavoritesProvider: LocalCatalogFavoritesProvider
    ) {
        self.catalogSourceClientFactory = catalogSourceClientFactory
        self.localCatalogFavoritesProvider = localCatalogFavoritesProvider
    }

    // MARK: - CatalogItemsProvider

    func configure(host: String, port: Int) {
        guard client == nil else { return }

        itemsSubject = .init()

        client = catalogSourceClientFactory.make(
            host: host,
            port: port,
            connectivityStateDelegate: self
        )
    }

    func disconnect() {
        _ = client?.channel.close()
        client = nil
    }

    func subscribe() -> AnyPublisher<[LinkItem], AppError> {
        guard let client = client else {
            return Fail(error: AppError.common(description: Strings.clientIsNotConfigured)).eraseToAnyPublisher()
        }

        call = client.fetch(.init(), callOptions: .none) { [weak self] catalog in
            guard let self = self else { return }

            self.localCatalogFavoritesProvider
                .favorites()
                .sink { [weak self, catalog] favorites in
                    let items = Self.mapCatalog(catalog: catalog, favorites: favorites)
                    self?.itemsSubject.send(items)
                }
                .store(in: &self.cancellables)
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

    private static func mapCatalog(
        catalog: Catalog_LinkItemsList,
        favorites: Set<String>
    ) -> [LinkItem] {
        catalog.items.map {
            LinkItem(
                id: $0.id,
                name: $0.name,
                urlString: $0.urlString,
                isFavorite: favorites.contains($0.id)
            )
        }
    }
}

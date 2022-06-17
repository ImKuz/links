import Models
import Combine
import ToolKit
import SharedInterfaces

public protocol CatalogClient: ConnectionObservable {
    func subscribe() -> AnyPublisher<[CatalogItem], AppError>
}

final class CatalogClientImpl: ConnectionObservable, CatalogClient {

    private let provider: CatalogItemsProvider
    private let host: String
    private let port: Int

    var connectivityPublisher: AnyPublisher<ConnectionState, Never> {
        provider.connectivity()
    }

    init(
        provider: CatalogItemsProvider,
        host: String,
        port: Int
    ) {
        self.provider = provider
        self.host = host
        self.port = port
    }

    deinit {
        provider.disconnect()
    }

    func subscribe() -> AnyPublisher<[CatalogItem], AppError> {
        configureIfNeeded(host: host, port: port)
        return self.provider.subscribe()
    }

    func connectivity() -> AnyPublisher<ConnectionState, Never> {
        provider.connectivity()
    }

    // MARK: - Private methods

    private func configureIfNeeded(host: String, port: Int) {
        provider.configure(host: host, port: port)
    }
}

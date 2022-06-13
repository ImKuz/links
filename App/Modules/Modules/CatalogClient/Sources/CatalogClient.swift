import Models
import Combine
import ToolKit

public protocol CatalogClient {
    func subscribe() -> AnyPublisher<[CatalogItem], AppError>
}

final class CatalogClientImpl: CatalogClient {

    private let provider: CatalogItemsProvider
    private let host: String
    private let port: Int

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

    func configureIfNeeded(host: String, port: Int) {
        provider.configure(host: host, port: port)
    }
}

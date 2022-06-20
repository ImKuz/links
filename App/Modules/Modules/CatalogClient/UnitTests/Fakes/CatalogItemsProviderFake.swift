import Combine
import Models
import ToolKit

@testable import CatalogClient

final class CatalogItemsProviderFake: CatalogItemsProvider {

    var host: String?
    var port: Int?
    var isDisconnected = false

    var itemsSubject = PassthroughSubject<[CatalogItem], AppError>()
    var connectivitySubject = PassthroughSubject<ConnectionState, Never>()

    func configure(host: String, port: Int) {
        self.host = host
        self.port = port
    }

    func disconnect() {
        isDisconnected = true
    }

    func subscribe() -> AnyPublisher<[CatalogItem], AppError> {
        itemsSubject.share().eraseToAnyPublisher()
    }

    func connectivity() -> AnyPublisher<ConnectionState, Never> {
        connectivitySubject.share().eraseToAnyPublisher()
    }
}

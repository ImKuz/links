import IdentifiedCollections
import ToolKit
import Models
import Combine
import CatalogClient
import SharedInterfaces

final class RemoteCatalogSource: CatalogSource, ConnectionObservable {

    private let client: CatalogClient

    let permissions: CatalogDataSourcePermissions = .read

    var connectivityPublisher: AnyPublisher<ConnectionState, Never> {
        client.connectivityPublisher
    }

    init(client: CatalogClient) {
        self.client = client
    }

    func subscribe() -> AnyPublisher<IdentifiedArrayOf<CatalogItem>, AppError> {
        client
            .subscribe()
            .map { IdentifiedArrayOf(uniqueElements: $0) }
            .eraseToAnyPublisher()
    }
}

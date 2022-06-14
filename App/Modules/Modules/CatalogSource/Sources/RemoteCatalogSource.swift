import IdentifiedCollections
import ToolKit
import Models
import Combine
import CatalogClient
import SharedInterfaces

final class RemoteCatalogSource: CatalogSource {

    let permissions: CatalogDataSourcePermissions = .read
    private var client: CatalogClient?

    func set(client: CatalogClient) {
        self.client = client
    }

    func subscribe() -> AnyPublisher<IdentifiedArrayOf<CatalogItem>, AppError> {
        guard let client = client else {
            return Fail(error: AppError.common(description: "Client is not instantiated")).eraseToAnyPublisher()
        }

        return client
            .subscribe()
            .map { IdentifiedArrayOf(uniqueElements: $0) }
            .eraseToAnyPublisher()
    }
}

import IdentifiedCollections
import ToolKit
import Models
import Combine
import CatalogClient
import SharedInterfaces

final class RemoteCatalogSource: CatalogSource, ConnectionObservable {

    let permissions: CatalogDataSourcePermissions = .read

    private let client: CatalogClient
    private let favoritesCatalogSourceHelper: FavoritesCatalogSourceHelper

    var connectivityPublisher: AnyPublisher<ConnectionState, Never> {
        client.connectivityPublisher
    }

    init(
        client: CatalogClient,
        favoritesCatalogSourceHelper: FavoritesCatalogSourceHelper
    ) {
        self.client = client
        self.favoritesCatalogSourceHelper = favoritesCatalogSourceHelper
    }

    func subscribe() -> AnyPublisher<IdentifiedArrayOf<CatalogItem>, AppError> {
        client
            .subscribe()
            .map { IdentifiedArrayOf(uniqueElements: $0) }
            .eraseToAnyPublisher()
    }

    func setIsFavorite(id: CatalogItem.ID, isFavorite: Bool) -> AnyPublisher<Void, AppError> {
        favoritesCatalogSourceHelper.setIsFavorite(id: id, isFavorite: isFavorite)
    }
}

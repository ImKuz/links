import Models
import Database
import ToolKit
import Combine

protocol FavoritesCatalogSourceHelper {
    func setIsFavorite(id: LinkItem.ID, isFavorite: Bool) -> AnyPublisher<Void, AppError>
    func isItemFavorite(id: LinkItem.ID) -> AnyPublisher<Bool, AppError>
}

final class FavoritesCatalogSourceHelperImpl: FavoritesCatalogSourceHelper {

    private let databaseService: DatabaseService

    init(databaseService: DatabaseService) {
        self.databaseService = databaseService
    }

    func setIsFavorite(id: LinkItem.ID, isFavorite: Bool) -> AnyPublisher<Void, AppError> {
        databaseService
            .write { context in
                let items = try context.read(
                    type: LinkItemEntity.self,
                    request: .init(predicate: .init(format: "itemId == %@", id))
                )

                if let entity = items.first {
                    entity.isFavorite = isFavorite
                    try context.update(entity)
                } else {
                    throw AppError.common(description: "")
                }

                try context.save()
            }
            .mapError { _ in AppError.businessLogic("Unable to make item favorite") }
            .eraseToAnyPublisher()
    }

    func isItemFavorite(id: LinkItem.ID) -> AnyPublisher<Bool, AppError> {
        databaseService
            .fetch(
                LinkItemEntity.self,
                request: .init(predicate: .init(format: "itemId == %@", id))
            )
            .mapError { _ in AppError.businessLogic("Unable to check item isFavorite status") }
            .map { $0.first?.isFavorite == true }
            .eraseToAnyPublisher()
    }
}

import Models
import Database
import ToolKit
import Combine

protocol FavoritesCatalogSourceHelper {
    func setIsFavorite(item: LinkItem, isFavorite: Bool) -> AnyPublisher<Void, AppError>
}

final class FavoritesCatalogSourceHelperImpl: FavoritesCatalogSourceHelper {

    private let databaseService: DatabaseService

    init(databaseService: DatabaseService) {
        self.databaseService = databaseService
    }

    func setIsFavorite(item: LinkItem, isFavorite: Bool) -> AnyPublisher<Void, AppError> {
        databaseService
            .write { context in
                let items = try context.read(
                    type: LinkItemEntity.self,
                    request: .init(predicate: .init(format: "itemId == %@", item.id))
                )

                if let entity = items.first {
                    entity.isFavorite = isFavorite
                    try context.update(entity)
                } else if isFavorite {
                    let entity = item.convertToEntity(withIndex: 0)
                    entity.isFavorite = true
                    try context.create(entity)
                }

                try context.save()
            }
            .mapError { _ in AppError.businessLogic("Unable to make item favorite") }
            .eraseToAnyPublisher()
    }
}

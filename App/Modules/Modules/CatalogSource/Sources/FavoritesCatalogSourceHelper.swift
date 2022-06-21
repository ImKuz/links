import Models
import Database
import ToolKit
import Combine

protocol FavoritesCatalogSourceHelper {
    func setIsFavorite(id: Models.CatalogItem.ID, isFavorite: Bool) -> AnyPublisher<Void, AppError>
}

final class FavoritesCatalogSourceHelperImpl: FavoritesCatalogSourceHelper {

    private let databaseService: DatabaseService

    init(databaseService: DatabaseService) {
        self.databaseService = databaseService
    }

    func setIsFavorite(id: Models.CatalogItem.ID, isFavorite: Bool) -> AnyPublisher<Void, AppError> {
        databaseService
            .write { context in
                let items = try context.read(
                    type: Database.CatalogItem.self,
                    request: .init(predicate: .init(format: "itemId == %@", id.description))
                )

                guard let entity = items.first else { return }

                entity.isFavorite = isFavorite

                try context.update(entity)
                try context.save()
            }
            .mapError { _ in AppError.businessLogic("Unable to make item favorite") }
            .eraseToAnyPublisher()
    }
}

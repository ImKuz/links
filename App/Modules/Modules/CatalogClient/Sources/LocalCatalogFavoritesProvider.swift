import Combine
import Database

protocol LocalCatalogFavoritesProvider {
    func favorites() -> AnyPublisher<Set<String>, Never>
}

final class LocalCatalogFavoritesProviderImpl: LocalCatalogFavoritesProvider {

    private let database: DatabaseService

    init(database: DatabaseService) {
        self.database = database
    }

    func favorites() -> AnyPublisher<Set<String>, Never> {
        database
            .fetch(
                CatalogItem.self,
                request: .init(predicate: .init(format: "isFavorite == YES"))
            )
            .map {
                $0.reduce(into: Set<String>()) { list, item in
                    list.insert(item.id)
                }
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}

import Combine
import Database
import ToolKit
import Models
import IdentifiedCollections
import Foundation

final class DatabaseCatalogSource: CatalogSource {

    private(set) var permissions: CatalogDataSourcePermissions = .all

    private var entitiesSubject = PassthroughSubject<IdentifiedArrayOf<LinkItemEntity>, AppError>()
    private var cancellables = [AnyCancellable]()
    private let databaseService: DatabaseService
    private let topLevelPredicate: NSPredicate?
    private let favoritesCatalogSourceHelper: FavoritesCatalogSourceHelper

    init(
        databaseService: DatabaseService,
        favoritesCatalogSourceHelper: FavoritesCatalogSourceHelper,
        topLevelPredicate: NSPredicate?,
        overridingPermissions: CatalogDataSourcePermissions?
    ) {
        self.databaseService = databaseService
        self.topLevelPredicate = topLevelPredicate
        self.favoritesCatalogSourceHelper = favoritesCatalogSourceHelper

        if let overridingPermissions = overridingPermissions {
            permissions.override(with: overridingPermissions)
        }

        subscribeToDatabaseUpdates()
    }

    // MARK: - CatalogSource

    func subscribe() -> AnyPublisher<IdentifiedArrayOf<LinkItem>, AppError> {
        defer { updateItems() }

        entitiesSubject = .init()

        return entitiesSubject
            .map { items in
                let mappedItems = items.map { $0.convertToModel() }
                return IdentifiedArrayOf<LinkItem>(uniqueElements: mappedItems)
            }
            .share()
            .eraseToAnyPublisher()
    }

    func delete(itemId: LinkItem.ID) -> AnyPublisher<Void, AppError> {
        databaseService
            .write { context in
                let items = try context.read(
                    type: LinkItemEntity.self,
                    request: .init(predicate: .init(format: "itemId == %@", itemId))
                )

                guard let item = items.first else { return }

                try context.delete(item)
                try context.updateIndices(from: Int(item.index))
                try context.save()
            }
            .mapError { _ in AppError.businessLogic("Unable to delete items") }
            .eraseToAnyPublisher()
    }

    func move(from: Int, to: Int) -> AnyPublisher<Void, AppError> {
        fetchItems()
            .map { IdentifiedArray(uniqueElements: $0) }
            .mapError { _ in AppError.businessLogic("Unable to fetch items") }
            .withUnretained(self)
            .flatMap { strongSelf, items -> AnyPublisher<Void, AppError> in
                strongSelf.databaseService
                    .write { context in
                        var newItems = items

                        let item = newItems.remove(at: from)
                        newItems.insert(item, at: to)

                        try context.updateIndices(items: &newItems, offset: min(from, to))
                        try context.save()
                    }
                    .mapError { _ in AppError.businessLogic("Unable to move items") }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func add(item: LinkItem) -> AnyPublisher<Void, AppError> {
        databaseService
            .write { context in
                try context.updateIndices(from: 0, indexOffset: 1)
                try context.create(item.convertToEntity(withIndex: 0))
                try context.save()
            }
            .mapError { _ in
                AppError.businessLogic("Unable to add item")
            }
            .eraseToAnyPublisher()
    }

    func setIsFavorite(item: LinkItem, isFavorite: Bool) -> AnyPublisher<Void, AppError> {
        favoritesCatalogSourceHelper
            .setIsFavorite(item: item, isFavorite: isFavorite)
    }

    // MARK: - Private methods

    private func subscribeToDatabaseUpdates() {
        databaseService
            .contentUpdatePublisher
            .sink { [weak self] in
                self?.updateItems()
            }
            .store(in: &cancellables)
    }

    private func fetchItems() -> AnyPublisher<[LinkItemEntity], Error> {
        databaseService.fetch(
            LinkItemEntity.self,
            request: .init(
                sortDescriptor: .init(key: "index", ascending: true),
                predicate: topLevelPredicate
            )
        )
    }

    private func updateItems() {
        fetchItems()
            .mapError { _ in
                AppError.common(description: "Unable to update items")
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.entitiesSubject.send(completion: .failure(error))
                    }
                },
                receiveValue: { [weak self] items in
                    let array = IdentifiedArrayOf<LinkItemEntity>(uniqueElements: items)
                    self?.entitiesSubject.send(array)
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Context Helpers

private extension Database.Context {

    func readCatalogItems(offset: Int = 0) throws -> [LinkItemEntity] {
        try read(
            type: LinkItemEntity.self,
            request: .init(
                sortDescriptor: .init(key: "index", ascending: true),
                fetchOffset: offset
            )
        )
    }

    func updateIndices(
        items: inout IdentifiedArrayOf<LinkItemEntity>,
        offset: Int = 0,
        indexOffset: Int = 0
    ) throws {
        guard !items.isEmpty else { return }
        var sliceItems = [LinkItemEntity]()

        if items.count == 1, let first = items.first {
            sliceItems = [first]
        } else {
            sliceItems = Array(items[offset..<items.endIndex])
        }

        sliceItems.forEach { item in
            let index = items.index(id: item.id)!
            items[id: item.id]?.index = Int16(index + indexOffset)
        }

        try update(Array(items))
        try save()
    }

    func updateIndices(
        from offset: Int,
        indexOffset: Int = 0
    ) throws {
        let items = try readCatalogItems(offset: offset)
        var array = IdentifiedArrayOf<LinkItemEntity>(uniqueElements: items)

        try updateIndices(
            items: &array,
            offset: offset,
            indexOffset: indexOffset
        )
    }
}

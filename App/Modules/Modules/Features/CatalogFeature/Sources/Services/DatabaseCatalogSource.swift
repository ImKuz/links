import Combine
import Database
import ToolKit
import Models
import IdentifiedCollections
import Foundation
import SharedInterfaces

final class DatabaseCatalogSource: CatalogSource {

    let permissions: CatalogDataSourcePermissions = .all

    private var itemsSubject = PassthroughSubject<IdentifiedArrayOf<Database.CatalogItem>, AppError>()
    private let databaseService: DatabaseService
    private let cancellables = [AnyCancellable]()

    init(databaseService: DatabaseService) {
        self.databaseService = databaseService
    }

    // MARK: - CatalogSource

    func subscribe() -> AnyPublisher<IdentifiedArrayOf<Models.CatalogItem>, AppError> {
        defer { updateItems() }
        itemsSubject = .init()

        return itemsSubject
            .map { items in
                let mappedItems = items.map { $0.convertToModel() }
                return IdentifiedArrayOf<Models.CatalogItem>(uniqueElements: mappedItems)
            }
            .share()
            .eraseToAnyPublisher()
    }

    func delete(_ item: Models.CatalogItem) -> AnyPublisher<Void, AppError> {
        Future { [weak self] promise in
            self?.databaseService.writeAsync { context in
                let items = try context.read(
                    type: Database.CatalogItem.self,
                    request: .init(predicate: .init(format: "itemId == %@", item.id))
                )

                guard let item = items.first else { return }

                try context.delete(item)
                try context.updateIndices(from: Int(item.index))
                try context.save()
            } completion: {
                self?.updateItems()
                Self.completion(promise: promise, result: $0)
            }
        }
        .eraseToAnyPublisher()
    }

    func move(from: Int, to: Int) -> AnyPublisher<Void, AppError> {
        fetchItems()
            .map { IdentifiedArray(uniqueElements: $0) }
            .mapError { _ in AppError.businessLogic("Unable to fethc items from the database") }
            .flatMap { items -> Future<Void, AppError> in
                Future { [weak self] promise in
                    self?.databaseService.writeAsync { context in
                        var newItems = items

                        let item = newItems.remove(at: from)
                        newItems.insert(item, at: to)

                        try context.updateIndices(items: &newItems, offset: min(from, to))
                        try context.save()
                    } completion: {
                        self?.updateItems()
                        Self.completion(promise: promise, result: $0)
                    }
                }
            }
            .eraseToAnyPublisher()
    }

    func add(item: Models.CatalogItem) -> AnyPublisher<Void, AppError> {
        Future { [weak self] promise in
            self?.databaseService.writeAsync { context in
                try context.create(item.convertToEntity(withIndex: 0))
                try context.updateIndices(from: 0)
                try context.save()
            } completion: {
                self?.updateItems()
                Self.completion(promise: promise, result: $0)
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Private methods

    private func fetchItems() -> AnyPublisher<[Database.CatalogItem], Error> {
        Future { [weak self] promise in
            self?.fetchItems { promise($0) }
        }.eraseToAnyPublisher()
    }

    private func fetchItems(completion: @escaping (Result<[Database.CatalogItem], Error>) -> Void) {
        databaseService.fetchAsync(
            Database.CatalogItem.self,
            request: .init(sortDescriptor: .init(key: "index", ascending: true)),
            completion: completion
        )
    }

    private func updateItems(completion: (() -> ())? = nil) {
        fetchItems { [weak self] result in
            defer { completion?() }

            switch result {
            case let .success(fetchedItems):
                let array = IdentifiedArrayOf<Database.CatalogItem>(uniqueElements: fetchedItems)
                self?.itemsSubject.send(array)
            case .failure:
                let error = AppError.common(description: "Unable to update items")
                self?.itemsSubject.send(completion: .failure(error))
            }
        }
    }

    private static func completion(
        promise: @escaping (Result<Void, AppError>) -> Void,
        result: Result<Void, Error>
    ) {
        switch result {
        case let .failure(error):
            print(error.localizedDescription)
            promise(.failure(.common(description: "UnableToAdd")))
        case .success:
            promise(.success(()))
        }
    }
}

private extension Database.Context {

    func readCatalogItems(offset: Int = 0) throws -> [Database.CatalogItem] {
        try read(
            type: Database.CatalogItem.self,
            request: .init(
                sortDescriptor: .init(key: "index", ascending: true),
                fetchOffset: offset
            )
        )
    }

    func updateIndices(items: inout IdentifiedArrayOf<Database.CatalogItem>, offset: Int = 0) throws {
        let slice = items[offset..<items.endIndex]

        slice.forEach { item in
            let index = items.index(id: item.id)!
            items[id: item.id]?.index = Int16(index)
        }

        try update(Array(items))
        try save()
    }

    func updateIndices(from offset: Int) throws {
        let items = try readCatalogItems(offset: offset)
        var array = IdentifiedArrayOf<Database.CatalogItem>(uniqueElements: items)
        try updateIndices(items: &array, offset: offset)
    }
}

// MARK: - Mapping

private extension Models.CatalogItem {

    func convertToEntity(withIndex index: Int) -> Database.CatalogItem {
        let contentString: String
        let contentType: String

        switch content {
        case let .link(url):
            contentString = url.absoluteString
            contentType = "link"
        case let .text(string):
            contentString = string
            contentType = "text"
        }

        return .init(
            storeId: UUID().uuidString,
            itemId: id,
            name: _name,
            content: contentString,
            contentType: contentType,
            isFavorite: false,
            index: Int16(index),
            remoteServerId: nil
        )
    }
}

private extension Database.CatalogItem {

    func convertToModel() -> Models.CatalogItem {
        let itemContent: CatalogItemContent

        switch contentType {
        case "link":
            if let url = URL(string: content) {
                itemContent = .link(url)
            } else {
                itemContent = .text(content)
            }
        case "text":
            itemContent = .text(content)
        default:
            fatalError("Unsupported content type!")
        }

        return .init(
            id: itemId,
            name: name,
            content: itemContent
        )
    }
}

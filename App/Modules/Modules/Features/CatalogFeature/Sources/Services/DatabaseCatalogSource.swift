import Combine
import Database
import ToolKit
import Models
import IdentifiedCollections
import Foundation
import SharedInterfaces

final class DatabaseCatalogSource: CatalogSource {

    let permissions: CatalogDataSourcePermissions = .all

    private let itemsSubject: CurrentValueSubject<IdentifiedArrayOf<Models.CatalogItem>, AppError>
    private let databaseService: DatabaseService
    private let cancellables = [AnyCancellable]()
    private var items: IdentifiedArrayOf<Database.CatalogItem>?

    init(databaseService: DatabaseService) {
        self.databaseService = databaseService
        itemsSubject = .init([])
    }

    // MARK: - CatalogSource

    func read() -> AnyPublisher<IdentifiedArrayOf<Models.CatalogItem>, AppError> {
        fetchOrGetCurrentItems()
            .map { items in
                let mappedItems = items.map { $0.convertToModel() }
                return IdentifiedArrayOf<Models.CatalogItem>(uniqueElements: mappedItems)
            }
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
                Self.completion(promise: promise, result: $0)
            }
        }
        .eraseToAnyPublisher()
    }

    func move(from: Int, to: Int) -> AnyPublisher<Void, AppError> {
        fetchOrGetCurrentItems()
            .flatMap { items in
                Future { [weak self] promise in
                    self?.databaseService.writeAsync { context in
                        var items = items

                        items.move(fromOffsets: .init(integer: from), toOffset: to)

                        try context.updateIndices(items: &items, offset: min(from, to))
                        try context.save()
                    } completion: {
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
                Self.completion(promise: promise, result: $0)
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Private methods

    private func fetchOrGetCurrentItems() -> AnyPublisher<IdentifiedArrayOf<Database.CatalogItem>, AppError> {
        if let items = items {
            return Just(items)
                .setFailureType(to: AppError.self)
                .eraseToAnyPublisher()
        }

        return Future { [weak self] promise in
            self?.databaseService.fetchAsync(
                Database.CatalogItem.self,
                request: .init(sortDescriptor: .init(key: "index", ascending: true))
            ) { result in
                switch result {
                case let .success(fetchedItems):
                    let array = IdentifiedArrayOf<Database.CatalogItem>(uniqueElements: fetchedItems)
                    promise(.success(array))
                case let .failure(error):
                    promise(.failure(AppError.common(description: error.localizedDescription)))
                }
            }
        }
        .eraseToAnyPublisher()
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

    private func updateItems() {
        databaseService.fetchAsync(
            Database.CatalogItem.self,
            request: .init(
                sortDescriptor: .init(key: "index", ascending: true)
            )
        ) { [weak itemsSubject] result in
            guard case let .success(items) = result else { return }
            let rows = items.map { $0.convertToModel() }
            itemsSubject?.send(.init(uniqueElements: rows))
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

        try update(Array(slice))
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

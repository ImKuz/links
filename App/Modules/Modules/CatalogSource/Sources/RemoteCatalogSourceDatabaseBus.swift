import IdentifiedCollections
import Models
import Combine
import ToolKit
import Database
import Foundation

protocol RemoteCatalogSourceDatabaseBus: AnyObject {

    var output: AnyPublisher<IdentifiedArrayOf<Models.CatalogItem>, AppError> { get }

    func reset()
    func pass(error: AppError)
    func pass(items: IdentifiedArrayOf<Models.CatalogItem>)
    func synchronizeState()
}

final class RemoteCatalogSourceDatabaseBusImpl: RemoteCatalogSourceDatabaseBus {

    private let databaseService: DatabaseService
    private var outputSubject = CurrentValueSubject<IdentifiedArrayOf<Models.CatalogItem>, AppError>([])
    private var cancellables = [AnyCancellable]()

    var output: AnyPublisher<IdentifiedArrayOf<Models.CatalogItem>, AppError> {
        outputSubject
            .share()
            .eraseToAnyPublisher()
    }

    init(databaseService: DatabaseService) {
        self.databaseService = databaseService

        databaseService
            .contentUpdatePublisher
            .sink { [weak self] _ in
                self?.synchronizeState()
            }
            .store(in: &cancellables)
    }

    // MARK: - RemoteCatalogSourceDatabaseBus

    func reset() {
        outputSubject = .init([])
    }

    func pass(error: AppError) {
        outputSubject.send(completion: .failure(error))
    }

    func pass(items: IdentifiedArrayOf<Models.CatalogItem>) {
        synchronizeItems(items)
    }

    func synchronizeState() {
        guard !outputSubject.value.isEmpty else { return }
        synchronizeItems(outputSubject.value)
    }

    private func synchronizeItems(_ items: IdentifiedArrayOf<Models.CatalogItem>) {
        let itemIds = items
            .elements
            .map(\.id)

        let predicate = NSPredicate(format: "itemId IN %@", itemIds)

        databaseService
            .fetch(
                Database.CatalogItem.self,
                request: .init(predicate: predicate)
            )
            .map { [items] storedItems -> IdentifiedArrayOf<Models.CatalogItem> in
                var newItems = items
                let storedItems = IdentifiedArray(uniqueElements: storedItems)

                for (index, item) in newItems.elements.enumerated() {
                    var isFavorite = false

                    if let storedItem = storedItems[id: item.id] {
                        isFavorite = storedItem.isFavorite
                    }

                    newItems.update(.init(
                        id: item.id,
                        name: item.name,
                        content: item.content,
                        isFavorite: isFavorite
                    ), at: index)
                }

                return newItems
            }
            .mapError { _ in
                AppError.businessLogic("Unable to synchronize state")
            }
            .sink(
                receiveCompletion: { [weak self] in
                    if case let .failure(error) = $0 {
                        self?.outputSubject.send(completion: .failure(error))
                    }
                },
                receiveValue: { [weak self] items in
                    self?.outputSubject.send(items)
                }
            )
            .store(in: &cancellables)
    }
}

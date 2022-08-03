import IdentifiedCollections
import Models
import Combine
import ToolKit
import Database
import Foundation

protocol RemoteCatalogSourceDatabaseBus: AnyObject {

    var output: AnyPublisher<IdentifiedArrayOf<LinkItem>, AppError> { get }

    func reset()
    func pass(error: AppError)
    func pass(items: IdentifiedArrayOf<LinkItem>)
    func synchronizeState()
}

final class RemoteCatalogSourceDatabaseBusImpl: RemoteCatalogSourceDatabaseBus {

    private let databaseService: DatabaseService
    private var outputSubject = CurrentValueSubject<IdentifiedArrayOf<LinkItem>, AppError>([])
    private var cancellables = [AnyCancellable]()

    var output: AnyPublisher<IdentifiedArrayOf<LinkItem>, AppError> {
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

    func pass(items: IdentifiedArrayOf<LinkItem>) {
        synchronizeItems(items)
    }

    func synchronizeState() {
        guard !outputSubject.value.isEmpty else { return }
        synchronizeItems(outputSubject.value)
    }

    private func synchronizeItems(_ items: IdentifiedArrayOf<LinkItem>) {
        let predicate = NSPredicate(
            format: "itemId IN %@",
            items.elements.map(\.id)
        )

        databaseService
            .fetch(
                LinkItemEntity.self,
                request: .init(predicate: predicate)
            )
            .map { [items] storedItems -> IdentifiedArrayOf<LinkItem> in
                var newItems = items
                let storedItems = IdentifiedArray(uniqueElements: storedItems)

                for (index, item) in newItems.elements.enumerated() {
                    var isFavorite = false

                    if let storedItem = storedItems[id: item.id] {
                        isFavorite = storedItem.isFavorite
                    }

                    let linkItem = LinkItem(
                        id: item.id,
                        name: item.name,
                        urlString: item.urlString,
                        isFavorite: isFavorite
                    )

                    newItems.update(linkItem, at: index)
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

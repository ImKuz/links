import Contracts
import Combine
import IdentifiedCollections
import Models
import ToolKit
import SharedInterfaces

final class CatalogSourceMock: CatalogSource {

    let isMoveSupported = true

    private let itemsSubject: CurrentValueSubject<IdentifiedArrayOf<CatalogItem>, AppError>

    init() {
        itemsSubject = .init([
            .init(id: "1", name: "Test1", content: .text("foo")),
            .init(id: "2", name: "Test2", content: .text("foo")),
            .init(id: "3", name: "Test3", content: .text("foo")),
            .init(id: "4", name: "Test4", content: .text("foo")),
            .init(id: "5", name: "Test5", content: .text("foo"))
        ])
    }

    func read() -> AnyPublisher<IdentifiedArrayOf<CatalogItem>, AppError> {
        itemsSubject.eraseToAnyPublisher()
    }

    func delete(_ item: CatalogItem) -> AnyPublisher<Void, AppError> {
        var items = itemsSubject.value

        items.remove(item)
        itemsSubject.send(items)

        return Just<Void>(())
            .setFailureType(to: AppError.self)
            .eraseToAnyPublisher()
    }

    func move(from: Int, to: Int) -> AnyPublisher<Void, AppError> {
        var items = itemsSubject.value

        let temp = items.remove(at: from)
        items.insert(temp, at: to)

        itemsSubject.send(items)

        return Just<Void>(())
            .setFailureType(to: AppError.self)
            .eraseToAnyPublisher()
    }

    func add(item: CatalogItem) -> AnyPublisher<Void, AppError> {
        var items = itemsSubject.value

        items.append(item)

        itemsSubject.send(items)

        return Just<Void>(())
            .setFailureType(to: AppError.self)
            .eraseToAnyPublisher()
    }
}

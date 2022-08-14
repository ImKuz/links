import Combine
import IdentifiedCollections
import Models
import ToolKit

public protocol CatalogSource: AnyObject {

    var permissions: CatalogDataSourcePermissions { get }
    var isPersistable: Bool { get }

    func subscribe() -> AnyPublisher<IdentifiedArrayOf<LinkItem>, AppError>
    func delete(itemId: LinkItem.ID) -> AnyPublisher<Void, AppError>
    func move(from: Int, to: Int) -> AnyPublisher<Void, AppError>
    func add(item: LinkItem) -> AnyPublisher<Void, AppError>
    func contains(itemId: LinkItem.ID) -> AnyPublisher<Bool, AppError>

    func setIsFavorite(id: LinkItem.ID, isFavorite: Bool) -> AnyPublisher<Void, AppError>
}

public extension CatalogSource {

    private var message: String { "Operation is not permitted" }

    func subscribe() -> AnyPublisher<IdentifiedArrayOf<LinkItem>, AppError> {
        guard permissions.contains(.read) else {
            return Fail(error: AppError.businessLogic(message)).eraseToAnyPublisher()
        }

        assertionFailure("method \(#function) should be implemented in \(self) accoding to its permissions")
        return Empty().eraseToAnyPublisher()
    }

    func delete(itemId: LinkItem.ID) -> AnyPublisher<Void, AppError> {
        guard permissions.contains(.modify) else {
            return Fail(error: AppError.businessLogic(message)).eraseToAnyPublisher()
        }

        assertionFailure("method \(#function) should be implemented in \(self) accoding to its permissions")
        return Empty().eraseToAnyPublisher()
    }

    func move(from: Int, to: Int) -> AnyPublisher<Void, AppError> {
        guard permissions.contains(.modify) else {
            return Fail(error: AppError.businessLogic(message)).eraseToAnyPublisher()
        }

        assertionFailure("method \(#function) should be implemented in \(self) accoding to its permissions")
        return Empty().eraseToAnyPublisher()
    }

    func add(item: LinkItem) -> AnyPublisher<Void, AppError> {
        guard permissions.contains(.add) else {
            return Fail(error: AppError.businessLogic(message)).eraseToAnyPublisher()
        }

        assertionFailure("method \(#function) should be implemented in \(self) accoding to its permissions")
        return Empty().eraseToAnyPublisher()
    }

    func setIsFavorite(id: LinkItem.ID, isFavorite: Bool) -> AnyPublisher<Void, AppError> {
        guard permissions.contains(.favorites) else {
            return Fail(error: AppError.businessLogic(message)).eraseToAnyPublisher()
        }

        assertionFailure("method \(#function) should be implemented in \(self) accoding to its permissions")
        return Empty().eraseToAnyPublisher()
    }
}

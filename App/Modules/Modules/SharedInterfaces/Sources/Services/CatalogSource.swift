import Contracts
import Combine
import IdentifiedCollections
import Models
import ToolKit

public protocol CatalogSource: AnyObject {
    var isMoveSupported: Bool { get }

    func read() -> AnyPublisher<IdentifiedArrayOf<CatalogItem>, AppError>
    func delete(_ item: CatalogItem) -> AnyPublisher<Void, AppError>
    func move(from: Int, to: Int) -> AnyPublisher<Void, AppError>
    func add(item: CatalogItem) -> AnyPublisher<Void, AppError>
}

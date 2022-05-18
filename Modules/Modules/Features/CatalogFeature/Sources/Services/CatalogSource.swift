import Contracts
import Combine
import IdentifiedCollections
import ToolKit

protocol CatalogSource: AnyObject {
    var isMoveSupported: Bool { get } 

    func read() -> AnyPublisher<IdentifiedArrayOf<CatalogItem>, AppError>
    func delete(_ item: CatalogItem) -> AnyPublisher<Void, AppError>
    func move(item: CatalogItem, to index: Int) -> AnyPublisher<Void, AppError>
    func add(item: CatalogItem) -> AnyPublisher<Void, AppError>
}

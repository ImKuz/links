import Combine
import ComposableArchitecture
import Foundation
import SharedEnv
import ToolKit

final class CatalogEnvImpl: CatalogEnv {

    var prepareDropTarget: (Int, NSItemProvider?) -> Effect<CatalogItemDropTarget, AppError>
    var read: () -> Effect<IdentifiedArrayOf<CatalogItem>, AppError>
    var delete: (CatalogItem) -> Effect<Void, AppError>
    var move: (CatalogItem, Int) -> Effect<Void, AppError>
    var add: (CatalogItem) -> Effect<Void, AppError>

    private let catalogSource: CatalogSource

    init(catalogSource: CatalogSource) {
        self.catalogSource = catalogSource

        prepareDropTarget = Self.prepareDropTargetMethod

        read = { [unowned catalogSource] in
            catalogSource
                .read()
                .eraseToEffect()
        }

        delete = { [unowned catalogSource] item in
            catalogSource
                .delete(item)
                .eraseToEffect()
        }

        move = { [unowned catalogSource] item, index in
            catalogSource
                .move(item: item, to: index)
                .eraseToEffect()
        }

        add = { [unowned catalogSource] item in
            catalogSource
                .add(item: item)
                .eraseToEffect()
        }
    }

    private static func prepareDropTargetMethod(
        _ index: Int,
        _ itemProvider: NSItemProvider?
    ) -> Effect<CatalogItemDropTarget, AppError> {
        Future<CatalogItem, AppError> { promise in
            guard let itemProvider = itemProvider else {
                return promise(.failure(.common(description: "Invalid Input")))
            }

            itemProvider.loadObject(ofClass: CatalogItem.self) { item, error in
                if let item = item as? CatalogItem {
                    promise(.success(item))
                } else {
                    promise(.failure(.common(description: "Unable to parse NSItemProvider")))
                }
            }
        }
        .map { [index] in CatalogItemDropTarget(index: index, item: $0) }
        .eraseToEffect()
    }
}

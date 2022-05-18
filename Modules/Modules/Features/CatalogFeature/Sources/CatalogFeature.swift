import ComposableArchitecture
import Combine
import IdentifiedCollections
import ToolKit
import Foundation
import SharedEnv

// MARK: - State

struct CatalogState: Equatable {

    var items: IdentifiedArrayOf<CatalogItem>
    var cancellables = [AnyCancellable]()

    static var initial: Self {
        .init(items: [])
    }

    init(items: IdentifiedArrayOf<CatalogItem>) {
        self.items = items
    }
}

// MARK: - Action

enum CatalogAction: Equatable {
    case test
    case noAction
    case onAppear
    case itemsUpdated(Result<IdentifiedArrayOf<CatalogItem>, AppError>)
    case deleteRow(IndexSet)
    case dropItemHandle(Result<CatalogItemDropTarget, AppError>)
    case prepareDropTarget(index: Int, item: NSItemProvider?)
    case rowAction(id: CatalogItem.ID, action: CatalogRowAction)
    case discardEdit(IdentifiedArrayOf<CatalogItem>)
}

// MARK: - Enviroment

protocol CatalogEnv: AnyObject {
    var prepareDropTarget: (Int, NSItemProvider?) -> Effect<CatalogItemDropTarget, AppError> { get set }
    var read: () -> Effect<IdentifiedArrayOf<CatalogItem>, AppError> { get set }
    var delete: (_ item: CatalogItem) -> Effect<Void, AppError> { get set }
    var move: (_ item: CatalogItem, _ index: Int) -> Effect<Void, AppError> { get set }
    var add: (_ item: CatalogItem) -> Effect<Void, AppError> { get set }
}

// MARK: - Reducer

typealias CatalogReducerType = Reducer<CatalogState, CatalogAction, SystemEnv<CatalogEnv>>

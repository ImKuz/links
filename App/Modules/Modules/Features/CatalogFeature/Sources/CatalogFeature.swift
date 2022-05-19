import ComposableArchitecture
import Combine
import IdentifiedCollections
import ToolKit
import Foundation
import SharedEnv
import Models

// MARK: - State

struct CatalogState: Equatable {

    var title: String
    var titleMessage: String? = nil
    var items: IdentifiedArrayOf<CatalogItem>

    init(items: IdentifiedArrayOf<CatalogItem>, title: String) {
        self.title = title
        self.items = items
    }

    static func initial(title: String) -> Self {
        Self(items: [], title: title)
    }
}

// MARK: - Action

enum CatalogAction: Equatable {
    case updateData
    case addItemTap
    case itemsUpdated(Result<IdentifiedArrayOf<CatalogItem>, AppError>)
    case moveItem(from: Int, to: Int)
    case rowAction(id: CatalogItem.ID, action: CatalogRowAction)
    case titleMessage(text: String)
    case dismissAddItemForm
}

// MARK: - Enviroment

protocol CatalogEnv: AnyObject {
    func read() -> Effect<IdentifiedArrayOf<CatalogItem>, AppError>
    func delete(_ item: CatalogItem) -> Effect<Void, AppError>
    func move(_ from: Int, _ to: Int) -> Effect<Void, AppError>
    func add(_ item: CatalogItem) -> Effect<Void, AppError>

    func handleContent(_ content: CatalogItemContent) -> Effect<Void, Never>
    func showForm() -> Effect<CatalogAction, Never>
    func dismissPresetnedView() -> Effect<Void, Never>
}

// MARK: - Reducer

typealias CatalogReducerType = Reducer<CatalogState, CatalogAction, SystemEnv<CatalogEnv>>

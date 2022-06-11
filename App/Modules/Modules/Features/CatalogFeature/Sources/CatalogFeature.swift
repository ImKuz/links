import ComposableArchitecture
import Combine
import IdentifiedCollections
import ToolKit
import Foundation
import Models
import UIKit

// MARK: - State

struct CatalogState: Equatable {

    let mode: Mode

    var title: String
    var titleMessage: String? = nil
    var items: IdentifiedArrayOf<CatalogItem>

    var leftButton: ButtonConfig? = nil
    var rightButton: ButtonConfig? = nil

    init(
        mode: Mode,
        items: IdentifiedArrayOf<CatalogItem>,
        title: String
    ) {
        self.mode = mode
        self.title = title
        self.items = items
    }

    static func == (lhs: CatalogState, rhs: CatalogState) -> Bool {
        [
            lhs.mode == rhs.mode,
            lhs.title == rhs.title,
            lhs.titleMessage == rhs.titleMessage,
            lhs.items == rhs.items
        ].allSatisfy { $0 }
    }

    static func initial(mode: Mode, title: String) -> Self {
        Self(
            mode: mode,
            items: [],
            title: title
        )
    }

    struct ButtonConfig: Equatable {
        let title: String?
        let systemImageName: String?
    }

    enum Mode: Equatable {
        case local, remote
    }
}

// MARK: - Action

enum CatalogAction: Equatable {
    case viewDidLoad
    case suscribeToUpdates
    case leftButtonTap
    case rightButtonTap
    case itemsUpdated(Result<IdentifiedArrayOf<CatalogItem>, AppError>)
    case moveItem(from: Int, to: Int)
    case rowAction(id: CatalogItem.ID, action: CatalogRowAction)
    case titleMessage(text: String)
    case dismissAddItemForm
}

// MARK: - Enviroment

protocol CatalogEnv: AnyObject {
    var permissions: CatalogDataSourcePermissions { get }

    func subscribe() -> Effect<IdentifiedArrayOf<CatalogItem>, AppError>
    func delete(_ item: CatalogItem) -> Effect<Void, AppError>
    func move(_ from: Int, _ to: Int) -> Effect<Void, AppError>
    func add(_ item: CatalogItem) -> Effect<Void, AppError>

    func handleContent(_ content: CatalogItemContent) -> Effect<Void, Never>
    func showForm() -> Effect<CatalogAction, Never>
    func showErrorAlert(error: AppError) -> Effect<Void, Never>
    func dismissPresetnedView() -> Effect<Void, Never>
}

// MARK: - Reducer

typealias CatalogReducerType = Reducer<CatalogState, CatalogAction, CatalogEnv>

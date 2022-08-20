import ComposableArchitecture
import Combine
import IdentifiedCollections
import ToolKit
import Foundation
import Models
import UIKit
import LinkItemActions

// MARK: - Action

indirect enum CatalogAction: Equatable {

    case viewDidLoad
    case close
    case suscribeToUpdates
    case addLinkItem
    case connectionFailureInfo
    case handleConnectionStateChange(ConnectionState)
    case applicationStateUpdated
    case itemsUpdated(Result<IdentifiedArrayOf<LinkItem>, AppError>)
    case handleError(AppError)
    case titleMessage(text: String)
    case dismissAddItemForm
    case moveItem(from: Int, to: Int)
    case rowAction(id: LinkItem.ID, action: CatalogRowAction)
    case handleActionCompletion(action: CatalogAction)
}

// MARK: - Enviroment

protocol CatalogEnv: AnyObject {

    var permissions: CatalogDataSourcePermissions { get }
    var tapAction: CatalogRowAction { get }

    // MARK: Updates subscription

    func observeAppStateChanges() -> Effect<Void, Never>
    func observeConnectivity() -> Effect<ConnectionState, Never>
    func subscribeToCatalogUpdates() -> Effect<IdentifiedArrayOf<LinkItem>, AppError>

    // MARK: Catalog

    func reloadCatalog() -> Effect<Void, Never>
    func move(_ from: Int, _ to: Int) -> Effect<Void, AppError>
    func handleLinkItemAction(_ action: LinkItemAction, item: LinkItem) -> Effect<CatalogAction, AppError>
    func actionsProvider(itemId: LinkItem.ID) async -> [LinkItemAction.WithData]

    // MARK: Routing

    func showEditLinkForm(item: LinkItem?) -> Effect<CatalogAction, AppError>
    func showConnectionErrorSheet() -> Effect<CatalogAction, Never>
    func showErrorAlert(error: AppError) -> Effect<Void, Never>
    func dismissPresetnedView() -> Effect<Void, Never>
    func close() -> Effect<Void, Never>
}

// MARK: - Reducer

typealias CatalogReducerType = Reducer<CatalogState, CatalogAction, CatalogEnv>

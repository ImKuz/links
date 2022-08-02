import ComposableArchitecture
import Combine
import IdentifiedCollections
import ToolKit
import Foundation
import Models
import UIKit

// MARK: - Action

indirect enum CatalogAction: Equatable {
    case viewDidLoad
    case suscribeToUpdates
    case close
    case addLinkItem
    case connectionFailureInfo
    case handleConnectionStateChange(ConnectionState)
    case applicationStateUpdated
    case itemsUpdated(Result<IdentifiedArrayOf<LinkItem>, AppError>)
    case handleActionCompletion(action: CatalogAction)
    case handleError(AppError)
    case moveItem(from: Int, to: Int)
    case rowAction(id: LinkItem.ID, action: CatalogRowAction)
    case titleMessage(text: String)
    case dismissAddItemForm
}

// MARK: - Enviroment

protocol CatalogEnv: AnyObject {

    var permissions: CatalogDataSourcePermissions { get }
    var configurableActions: [CatalogRowAction] { get }
    var tapAction: CatalogRowAction { get }

    // MARK: Updates subscription

    func observeAppStateChanges() -> Effect<Void, Never>
    func observeConnectivity() -> Effect<ConnectionState, Never>
    func subscribeToCatalogUpdates() -> Effect<IdentifiedArrayOf<CatalogItem>, AppError>

    // MARK: Catalog

    func reloadCatalog() -> Effect<Void, Never>
    func delete(_ item: LinkItem) -> Effect<Void, AppError>
    func move(_ from: Int, _ to: Int) -> Effect<Void, AppError>
    func add(_ item: LinkItem) -> Effect<Void, AppError>
    func setIsFavorite(item: LinkItem, isFavorite: Bool) -> Effect<Void, AppError>

    // MARK: Content handling

    func followLink(item: LinkItem) -> Effect<Void, AppError>
    func copyLink(item: LinkItem) -> Effect<CatalogAction, AppError>

    // MARK: Routing

    func showEditLinkForm(item: LinkItem?) -> Effect<CatalogAction, AppError>
    func showConnectionErrorSheet() -> Effect<CatalogAction, Never>
    func showErrorAlert(error: AppError) -> Effect<Void, Never>
    func dismissPresetnedView() -> Effect<Void, Never>
    func close() -> Effect<Void, Never>
}

// MARK: - Reducer

typealias CatalogReducerType = Reducer<CatalogState, CatalogAction, CatalogEnv>

import ComposableArchitecture
import Combine
import IdentifiedCollections
import ToolKit
import Foundation
import Models
import UIKit

// MARK: - Action

enum CatalogAction: Equatable {
    case viewDidLoad
    case suscribeToUpdates
    case close
    case addItem
    case connectionFailureInfo
    case handleConnectionStateChange(ConnectionState)
    case itemsUpdated(Result<IdentifiedArrayOf<CatalogItem>, AppError>)
    case moveItem(from: Int, to: Int)
    case rowAction(id: CatalogItem.ID, action: CatalogRowAction)
    case titleMessage(text: String)
    case dismissAddItemForm
}

// MARK: - Enviroment

protocol CatalogEnv: AnyObject {
    var permissions: CatalogDataSourcePermissions { get }

    func observeConnectivity() -> Effect<ConnectionState, Never>
    func subscribe() -> Effect<IdentifiedArrayOf<CatalogItem>, AppError>
    func delete(_ item: CatalogItem) -> Effect<Void, AppError>
    func move(_ from: Int, _ to: Int) -> Effect<Void, AppError>
    func add(_ item: CatalogItem) -> Effect<Void, AppError>

    func handleContent(_ content: CatalogItemContent) -> Effect<Void, Never>
    func copyContent(_ content: String) -> Effect<Void, Never>
    func showForm() -> Effect<CatalogAction, Never>
    func showErrorAlert(error: AppError) -> Effect<Void, Never>
    func showConnectionErrorSheet() -> Effect<CatalogAction, Never>
    func dismissPresetnedView() -> Effect<Void, Never>
    func close() -> Effect<Void, Never>
}

// MARK: - Reducer

typealias CatalogReducerType = Reducer<CatalogState, CatalogAction, CatalogEnv>

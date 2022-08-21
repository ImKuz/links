import Combine
import ComposableArchitecture
import Foundation
import Models
import ToolKit
import UIKit
import Swinject
import CatalogSource
import FeatureSupport
import SharedHelpers
import LinkItemActions

final class CatalogEnvImpl: CatalogEnv {

    // MARK: - Private properties

    private let container: Container
    private let catalogSource: CatalogSource
    private let settings: SettingsHelper
    private let router: Router
    private let linkItemActionsService: LinkItemActionsService

    private let catalogUpdateSubject = PassthroughSubject<Void, Never>()
    private var cancellables = [AnyCancellable]()

    // MARK: - CatalogEnv properties

    var permissions: CatalogDataSourcePermissions {
        catalogSource.permissions
    }

    var catalogUpdatePublisher: AnyPublisher<Void, Never> {
        catalogUpdateSubject
            .share()
            .eraseToAnyPublisher()
    }

    var tapAction: CatalogRowAction {
        switch settings.linkTapBehaviour {
        case "edit":
            return .linkItemAction(.edit)
        case "open":
            return .linkItemAction(.open)
        default:
            return .linkItemAction(.edit)
        }
    }

    // MARK: - Init

    init(
        container: Container,
        catalogSource: CatalogSource,
        router: Router,
        settings: SettingsHelper,
        linkItemActionsService: LinkItemActionsService
    ) {
        self.container = container
        self.catalogSource = catalogSource
        self.router = router
        self.settings = settings
        self.linkItemActionsService = linkItemActionsService
    }

    // MARK: Updates subscription

    func observeAppStateChanges() -> Effect<Void, Never> {
        settings
            .changesPublisher
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    }

    func observeConnectivity() -> Effect<ConnectionState, Never> {
        if let connectivityPublisher = (catalogSource as? ConnectionObservable)?.connectivityPublisher {
            return connectivityPublisher.eraseToEffect()
        } else {
            return .none
        }
    }

    func subscribeToCatalogUpdates() -> Effect<IdentifiedArrayOf<LinkItem>, AppError> {
        catalogSource
            .subscribe()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    }

    // MARK: Catalog

    func reloadCatalog() -> Effect<Void, Never> {
        catalogUpdateSubject.send()
        return .none
    }

    func move(_ from: Int, _ to: Int) -> Effect<Void, AppError> {
        catalogSource
            .move(from: from, to: to)
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    }

    func handleLinkItemAction(_ action: LinkItemAction, item: LinkItem) -> Effect<CatalogAction, AppError> {
        linkItemActionsService
            .handle(
                action.withData(.init(itemId: item.id))
            )
            .map {
                CatalogAction.handleActionCompletion(
                    action: .rowAction(id: item.id, action: .linkItemAction($0.action))
                )
            }
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    }

    @MainActor
    func actionsProvider(itemId: LinkItem.ID) async -> [LinkItemAction.WithData] {
        do {
            return try await linkItemActionsService.actions(itemID: itemId, shouldShowEditAction: true)
        } catch {
            // TODO: Error handling
            return []
        }
    }

    // MARK: Routing

    func showEditLinkForm(item: LinkItem?) -> Effect<CatalogAction, AppError> {
        let item: LinkItem = item ?? .init()

        let input = EditLinkFeatureInterface.Input(
            catalogSource: catalogSource,
            item: item,
            router: router
        )

        guard let interface = container.resolve(EditLinkFeatureInterface.self, argument: input) else {
            return Effect(error: .common(description: "Unable to resolve EditLink Feature interface"))
        }

        router.presentView(view: interface.view)

        return interface
            .onFinishPublisher
            .setFailureType(to: AppError.self)
            .receive(on: DispatchQueue.main)
            .eraseToEffect { .dismissAddItemForm }
    }

    func showErrorAlert(error: AppError) -> Effect<Void, Never> {
        Future { [weak router] promise in
            let alertVC = UIAlertController(
                title: "Error has occured",
                message: error.description,
                preferredStyle: .alert
            )

            alertVC.addAction(
                .init(title: "Try again", style: .default) { _ in
                    promise(.success(()))
                }
            )

            alertVC.addAction(
                .init(title: "Dismiss", style: .cancel, handler: nil)
            )

            router?.presentAlert(controller: alertVC)
        }.eraseToEffect()
    }

    func showConnectionErrorSheet() -> Effect<CatalogAction, Never> {
        Future { [weak router] promise in
            let alertVC = UIAlertController(
                title: "Connection error has occured",
                message: "Check server app status or try again",
                preferredStyle: .actionSheet
            )

            alertVC.addAction(
                .init(title: "Try again", style: .default) { _ in
                    promise(.success(.suscribeToUpdates))
                }
            )

            alertVC.addAction(
                .init(title: "Disconnect", style: .cancel) { _ in
                    promise(.success(.close))
                }
            )

            router?.presentAlert(controller: alertVC)
        }.eraseToEffect()
    }

    func dismissPresetnedView() -> Effect<Void, Never> {
        Future { [self] promise in
            router.dismiss(isAnimated: true) {
                promise(.success(()))
            }
        }.eraseToEffect()
    }

    func close() -> Effect<Void, Never> {
        Future { [self] promise in
            router.pop(isAnimated: true)
            promise(.success(()))
        }.eraseToEffect()
    }
}

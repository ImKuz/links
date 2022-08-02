import Combine
import ComposableArchitecture
import Foundation
import Models
import ToolKit
import UIKit
import Swinject
import SharedInterfaces
import SharedHelpers

final class CatalogEnvImpl: CatalogEnv {

    // MARK: - Private properties

    private let container: Container
    private let catalogSource: CatalogSource
    private let settings: SettingsHelper
    private let pastboard: UIPasteboard
    private let router: Router
    private let urlOpener: URLOpener

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

    var configurableActions: [CatalogRowAction] {
        switch settings.linkTapBehaviour {
        case "edit":
            return [.follow]
        case "follow":
            return [.edit]
        default:
            return [.follow]
        }
    }

    var tapAction: CatalogRowAction {
        switch settings.linkTapBehaviour {
        case "edit":
            return .edit
        case "follow":
            return .follow
        default:
            return .edit
        }
    }

    // MARK: - Init

    init(
        container: Container,
        catalogSource: CatalogSource,
        pastboard: UIPasteboard,
        router: Router,
        urlOpener: URLOpener,
        settings: SettingsHelper
    ) {
        self.container = container
        self.catalogSource = catalogSource
        self.pastboard = pastboard
        self.router = router
        self.urlOpener = urlOpener
        self.settings = settings
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

    func subscribeToCatalogUpdates() -> Effect<IdentifiedArrayOf<CatalogItem>, AppError> {
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

    func delete(_ item: LinkItem) -> Effect<Void, AppError> {
        catalogSource
            .delete(item)
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    }

    func move(_ from: Int, _ to: Int) -> Effect<Void, AppError> {
        catalogSource
            .move(from: from, to: to)
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    }

    func add(_ item: LinkItem) -> Effect<Void, AppError> {
        catalogSource
            .add(item: item)
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    }

    func setIsFavorite(item: LinkItem, isFavorite: Bool) -> Effect<Void, AppError> {
        catalogSource
            .setIsFavorite(item: item, isFavorite: isFavorite)
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    }

    // MARK: Content handling

    func followLink(item: LinkItem) -> Effect<Void, AppError> {
        urlOpener
            .open(item.urlString)
            .eraseToEffect()
    }

    func copyLink(item: LinkItem) -> Effect<CatalogAction, AppError> {
        pastboard.string = item.urlString

        return Effect(
            value: .handleActionCompletion(
                action: .rowAction(id: item.id, action: .copy)
            )
        )
    }

    // MARK: Routing

    func showEditLinkForm(item: LinkItem?) -> Effect<CatalogAction, AppError> {
        let item: LinkItem = item ?? .init(
            name: "Untitled link",
            urlString: "",
            isFavorite: false
        )

        let input = EditLinkFeatureInterface.Input(
            catalogSource: catalogSource,
            item: item
        )

        guard let interface = container.resolve(EditLinkFeatureInterface.self, argument: input) else {
            return Effect(error: .common(description: "Unable to resolve EditLink Feature interface"))
        }

        router.presentView(view: interface.view)

        return interface
            .onFinishPublisher
            .setFailureType(to: AppError.self)
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

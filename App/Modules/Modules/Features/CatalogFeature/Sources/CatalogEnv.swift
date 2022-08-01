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

    private let container: Container
    private let catalogSource: CatalogSource
    private let settings: SettingsHelper
    private let pastboard: UIPasteboard
    private let router: Router

    private let catalogUpdateSubject = PassthroughSubject<Void, Never>()
    private var cancellables = [AnyCancellable]()

    var permissions: CatalogDataSourcePermissions {
        catalogSource.permissions
    }

    var catalogUpdatePublisher: AnyPublisher<Void, Never> {
        catalogUpdateSubject
            .share()
            .eraseToAnyPublisher()
    }

    var linkTapAction: CatalogAction.HandleContentAction {
        switch settings.linkTapBehaviour {
        case "copy":
            return .copy
        case "follow":
            return .follow
        default:
            return .follow
        }
    }

    init(
        container: Container,
        catalogSource: CatalogSource,
        pastboard: UIPasteboard,
        router: Router,
        settings: SettingsHelper
    ) {
        self.container = container
        self.catalogSource = catalogSource
        self.pastboard = pastboard
        self.router = router
        self.settings = settings
    }

    func reloadCatalog() -> Effect<Void, Never> {
        catalogUpdateSubject.send()
        return .none
    }

    func observeAppStateChanges() -> Effect<Void, Never> {
        settings
            .changesPublisher
            .eraseToEffect()
    }

    func observeConnectivity() -> Effect<ConnectionState, Never> {
        if let connectivityPublisher = (catalogSource as? ConnectionObservable)?.connectivityPublisher {
            return connectivityPublisher.eraseToEffect()
        } else {
            return .none
        }
    }

    func subscribe() -> Effect<IdentifiedArrayOf<CatalogItem>, AppError> {
        catalogSource
            .subscribe()
            .removeDuplicates()
            .eraseToEffect()
    }

    func delete(_ item: CatalogItem) -> Effect<Void, AppError> {
        catalogSource
            .delete(item)
            .eraseToEffect()
    }

    func move(_ from: Int, _ to: Int) -> Effect<Void, AppError> {
        catalogSource
            .move(from: from, to: to)
            .eraseToEffect()
    }

    func add(_ item: CatalogItem) -> Effect<Void, AppError> {
        catalogSource
            .add(item: item)
            .eraseToEffect()
    }

    func setIsFavorite(item: CatalogItem, isFavorite: Bool) -> Effect<Void, AppError> {
        catalogSource
            .setIsFavorite(item: item, isFavorite: isFavorite)
            .eraseToEffect()
    }

    func handleContent(_ content: CatalogItemContent) -> Effect<CatalogAction.HandleContentAction?, Never> {
        switch content {
        case let .link(url):
            switch settings.linkTapBehaviour {
            case "copy":
                return copyContent(url.absoluteString)
            case "follow":
                return followLink(url)
            default:
                return Effect(value: nil)
            }
        case let .text(string):
            return copyContent(string)
        }
    }

    func followLink(_ url: URL) -> Effect<CatalogAction.HandleContentAction?, Never> {
        UIApplication.shared.open(url)
        return Effect(value: .follow)
    }

    func copyContent(_ content: String) -> Effect<CatalogAction.HandleContentAction?, Never> {
        pastboard.string = content
        return Effect(value: .copy)
    }

    func showForm() -> Effect<CatalogAction, Never> {
        guard
            permissions.contains(.add),
            // TODO: Resolving should not be inside this class
            let interface = container.resolve(EditLinkFeatureInterface.self, argument: catalogSource)
        else {
            return .none
        }

        router.presentView(view: interface.view)

        return interface
            .onFinishPublisher
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

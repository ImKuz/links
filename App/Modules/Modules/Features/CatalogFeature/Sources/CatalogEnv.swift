import Combine
import ComposableArchitecture
import Foundation
import Models
import ToolKit
import UIKit
import Swinject
import SharedInterfaces

final class CatalogEnvImpl: CatalogEnv {

    private let container: Container
    private let catalogSource: CatalogSource
    private let pastboard: UIPasteboard
    private let router: Router
    private var cancellables = [AnyCancellable]()

    var permissions: CatalogDataSourcePermissions {
        catalogSource.permissions
    }

    init(
        container: Container,
        catalogSource: CatalogSource,
        pastboard: UIPasteboard,
        router: Router
    ) {
        self.container = container
        self.catalogSource = catalogSource
        self.pastboard = pastboard
        self.router = router
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

    func handleContent(_ content: CatalogItemContent) -> Effect<Void, Never> {
        switch content {
        case let .link(url):
            UIApplication.shared.open(url)
        case let .text(string):
            return copyContent(string)
        }

        return Just(()).eraseToEffect()
    }

    func copyContent(_ content: String) -> Effect<Void, Never> {
        pastboard.string = content
        return Just(()).eraseToEffect()
    }

    func showForm() -> Effect<CatalogAction, Never> {
        guard
            permissions.contains(.write),
            let interface = container.resolve(AddItemFeatureInterface.self, argument: catalogSource)
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

    func dismissPresetnedView() -> Effect<Void, Never> {
        Future { [self] promise in
            router.dismiss(isAnimated: true) {
                promise(.success(()))
            }
        }.eraseToEffect()
    }
}

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

    func read() -> Effect<IdentifiedArrayOf<CatalogItem>, AppError> {
        catalogSource
            .read()
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
            pastboard.string = string
        }

        return Just(()).eraseToEffect()
    }

    func showForm() -> Effect<CatalogAction, Never> {
        guard let interface = container.resolve(AddItemFeatureInterface.self, argument: catalogSource) else {
            return .none
        }

        router.presentView(view: interface.view)

        return interface
            .onFinishPublisher
            .eraseToEffect { .dismissAddItemForm }
    }

    func dismissPresetnedView() -> Effect<Void, Never> {
        Future { [self] promise in
            router.dismiss(isAnimated: true) {
                promise(.success(()))
            }
        }.eraseToEffect()
    }
}

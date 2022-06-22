import SharedInterfaces
import SwiftUI
import Swinject
import Models
import UIKit
import ToolKit

protocol RootTabViewsProvider {

    func view(for tabType: TabType) -> AnyView?
}

final class RootTabViewsProviderImpl: RootTabViewsProvider {

    private let container: Container

    init(container: Container) {
        self.container = container
    }

    // MARK: - RootTabViewsProvider

    func view(for tabType: TabType) -> AnyView? {
        switch tabType {
        case .favorites:
            return makeLocalCatalog(
                title: "Favorites",
                predicate: .init(format: "isFavorite == YES")
            )
        case .local:
            return makeLocalCatalog(
                title: "Local",
                predicate: nil
            )
        case .remote:
            return container.resolve(RemoteFeatureInterface.self)!.view
        }
    }

    private func makeLocalCatalog(
        title: String,
        predicate: NSPredicate?
    ) -> AnyView {
        let navigationController = UINavigationController()
        let router = container.resolve(Router.self, argument: navigationController)!

        let input = CatalogFeatureInterface.Input(
            router: router,
            title: title,
            mode: .local(
                .init(topLevelPredicate: predicate)
            )
        )

        let catalogView = container.resolve(
            CatalogFeatureInterface.self,
            name: "local",
            argument: input
        )!.viewController

        navigationController.pushViewController(catalogView, animated: false)
        return AnyView(UINavigationControllerHolder(navigationController: navigationController))
    }
}

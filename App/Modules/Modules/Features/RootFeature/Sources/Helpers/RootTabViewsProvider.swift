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
            let config = CatalogSourceConfig(
                permissionsOverride: [.read, .favorites],
                typeConfig: .local(
                    .init(topLevelPredicate: NSPredicate(format: "isFavorite == YES"))
                )
            )

            return makeLocalCatalog(
                title: "Favorites",
                config: config
            )
        case .local:
            let config = CatalogSourceConfig(
                permissionsOverride: nil,
                typeConfig: .local(.init(topLevelPredicate: nil))
            )

            return makeLocalCatalog(
                title: "Local",
                config: config
            )
        case .remote:
            return container.resolve(RemoteFeatureInterface.self)!.view
        }
    }

    private func makeLocalCatalog(
        title: String,
        config: CatalogSourceConfig
    ) -> AnyView {
        let navigationController = UINavigationController()
        let router = container.resolve(Router.self, argument: navigationController)!

        let input = CatalogFeatureInterface.Input(
            router: router,
            title: title,
            config: config
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

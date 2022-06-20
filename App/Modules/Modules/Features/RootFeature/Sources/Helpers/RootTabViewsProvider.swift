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
            fatalError("Not implemented")
        case .local:
            let navigationController = UINavigationController()
            let router = container.resolve(Router.self, argument: navigationController)!

            let input = CatalogFeatureInterface.Input(
                router: router,
                title: "Local",
                mode: .local(.init(topLevelPredicate: nil))
            )

            let catalogView = container.resolve(
                CatalogFeatureInterface.self,
                name: "local",
                argument: input
            )!.viewController

            navigationController.pushViewController(catalogView, animated: false)
            return AnyView(UINavigationControllerHolder(navigationController: navigationController))
        case .remote:
            return container.resolve(RemoteFeatureInterface.self)!.view
        }
    }
}

import ComposableArchitecture
import Database
import Swinject
import ToolKit
import Models
import SharedInterfaces
import SwiftUI
import UIKit

public struct CatalogFeatureAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {

        // MARK: - Local data source
        container.register(CatalogFeatureInterface.self, name: "local") { resolver in
            let databaseService = resolver.resolve(DatabaseService.self)!
            let source = DatabaseCatalogSource(databaseService: databaseService)

            let navigationController = UINavigationController()
            let router = container.resolve(Router.self, argument: navigationController)!

            let environment = CatalogEnvImpl(
                container: container,
                catalogSource: source,
                pastboard: UIPasteboard.general,
                router: router
            )

            let store = Store(
                initialState: .initial(title: "Local"),
                reducer: CatalogReducerFactory().make(),
                environment: environment
            )

            let viewController = CatalogViewController(store: store)
            navigationController.pushViewController(viewController, animated: false)

            let view = AnyView(
                UINavigationControllerHolder(navigationController: navigationController)
            )

            return CatalogFeatureInterface(view: view)
        }
    }
}

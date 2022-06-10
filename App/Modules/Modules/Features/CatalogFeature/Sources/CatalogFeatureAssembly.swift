import ComposableArchitecture
import Database
import Swinject
import ToolKit
import Models
import SharedInterfaces
import SwiftUI
import UIKit
import CatalogClient

public struct CatalogFeatureAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        registerLocalCatalog(container: container)
        registerRemoteCatalog(container: container)
    }

    private func registerLocalCatalog(container: Container) {
        container.register(CatalogFeatureInterface.self, name: "local") { resolver in
            let databaseService = resolver.resolve(DatabaseService.self)!
            let source = DatabaseCatalogSource(databaseService: databaseService)

            return createModule(
                container: container,
                source: source,
                title: "Local",
                isLocal: true
            )
        }
    }

    private func registerRemoteCatalog(container: Container) {
        let remoteDataSourceFactory: (Resolver, String, Int) -> CatalogFeatureInterface = { resolver, host, port in
            let client = resolver.resolve(CatalogClient.self, arguments: host, port)!
            let source = RemoteCatalogSource()
            source.set(client: client)

            return createModule(
                container: container,
                source: source,
                title: "Remote",
                isLocal: false
            )
        }

        container.register(
            CatalogFeatureInterface.self,
            name: "remote",
            factory: remoteDataSourceFactory
        )
    }

    private func createModule(
        container: Container,
        source: CatalogSource,
        title: String,
        isLocal: Bool
    ) -> CatalogFeatureInterface {
        let navigationController = UINavigationController()
        let router = container.resolve(Router.self, argument: navigationController)!

        let environment = CatalogEnvImpl(
            container: container,
            catalogSource: source,
            pastboard: UIPasteboard.general,
            router: router
        )

        let mode: CatalogState.Mode = isLocal ? .local : .remote

        let store = Store(
            initialState: .initial(mode: mode, title: title),
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

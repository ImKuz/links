import ComposableArchitecture
import Swinject
import ToolKit
import Models
import FeatureSupport
import CatalogSource
import SwiftUI
import UIKit
import SharedHelpers
import LinkItemActions

public struct CatalogFeatureAssembly: Assembly {

    enum CatalogKind: String, CaseIterable {
        case local
        case remote
    }

    public init() {}

    public func assemble(container: Container) {
        for kind in CatalogKind.allCases {
            registerCatalog(kind: kind, container: container)
        }
    }

    private func registerCatalog(kind: CatalogKind, container: Container) {
        let factory: (Resolver, CatalogFeatureInterface.Input) -> CatalogFeatureInterface = { resolver, input in
            let source = Self.dataSource(resolver: resolver, input: input)

            return createModule(
                container: container,
                source: source,
                router: input.router,
                title: input.title,
                isLocal: kind == .local
            )
        }

        container.register(
            CatalogFeatureInterface.self,
            name: kind.rawValue,
            factory: factory
        )
    }

    private static func dataSource(
        resolver: Resolver,
        input: CatalogFeatureInterface.Input
    ) -> CatalogSource {
        switch input.config.typeConfig {
        case .local:
            return resolver.resolve(
                CatalogSource.self,
                name: "local",
                argument: input.config
            )!
        case .remote:
            return resolver.resolve(
                CatalogSource.self,
                name: "remote",
                argument: input.config
            )!
        }
    }

    private func createModule(
        container: Container,
        source: CatalogSource,
        router: Router,
        title: String,
        isLocal: Bool
    ) -> CatalogFeatureInterface {
        let environment = CatalogEnvImpl(
            container: container,
            catalogSource: source,
            router: router,
            settings: container.resolve(SettingsHelper.self)!,
            linkItemActionsService: container.resolve(LinkItemActionsService.self, arguments: source, router)!
        )

        let store = Store(
            initialState: CatalogState(hasCloseButton: !isLocal, title: title),
            reducer: CatalogReducerFactory().make(),
            environment: environment
        )

        let viewController = CatalogViewController(
            store: store,
            catalogUpdatePublisher: environment.catalogUpdatePublisher
        )

        viewController.actionsProvider = { [weak environment] itemId in
            await environment?.actionsProvider(itemId: itemId) ?? []
        }

        return CatalogFeatureInterface(viewController: viewController)
    }
}

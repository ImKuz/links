import ComposableArchitecture
import Swinject
import ToolKit
import Models
import SharedInterfaces
import SwiftUI
import UIKit

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
            let source = Self.dataSource(
                resolver: resolver,
                input: input,
                kind: kind
            )

            let title: String = {
                switch kind {
                case .local:
                    return "Local"
                case .remote:
                    return "Remote"
                }
            }()

            let isLocal = kind == .local

            return createModule(
                container: container,
                source: source,
                router: input.router,
                title: title,
                isLocal: isLocal
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
        input: CatalogFeatureInterface.Input,
        kind: CatalogKind
    ) -> CatalogSource {
        switch kind {
        case .local:
            return resolver.resolve(CatalogSource.self, name: "local")!
        case .remote:
            guard let creds = input.credentials else {
                fatalError("Attempt to create remote CatalogSource without credentials!")
            }

            return resolver.resolve(
                CatalogSource.self,
                name: "remote",
                arguments: creds.host, creds.port
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
            pastboard: UIPasteboard.general,
            router: router
        )

        let store = Store(
            initialState: .initial(hasCloseButton: !isLocal, title: title),
            reducer: CatalogReducerFactory().make(),
            environment: environment
        )

        let rowMenuActionsProvider = CatalogRowMenuActionsProviderImpl(env: environment)

        let viewController = CatalogViewController(
            store: store,
            rowMenuActionsProvider: rowMenuActionsProvider
        )

        return CatalogFeatureInterface(viewController: viewController)
    }
}

import Swinject
import SharedHelpers
import FeatureSupport
import CatalogSource
import ToolKit

public struct LinkItemActionsServiceAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {

        container.register(LinkItemActionsHandler.self) { resolver, source, router in
            LinkItemActionsHandlerImpl(
                catalogSource: source,
                urlOpener: container.resolve(URLOpener.self)!,
                pasteboard: .general,
                router: router,
                featureResolver: container.resolve(FeatureResolver.self)!
            )
        }

        let linkItemActionsServiceFactory: (Resolver, CatalogSource, Router) -> LinkItemActionsService = {
            resolver, source, router in

            let actionsHandler = resolver.resolve(LinkItemActionsHandler.self, arguments: source, router)!
            return LinkItemActionsServiceImpl(catalogSource: source, actionHandler: actionsHandler)
        }

        container.register(LinkItemActionsService.self, factory: linkItemActionsServiceFactory)
    }
}

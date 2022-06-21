import Swinject
import Database

public struct CatalogClientAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {

        let factory: (Resolver, String, Int) -> CatalogClient = { resolver, host, port in
            let catalogSourceClientFactory = CatalogSourceClientFactoryImpl()
            let localCatalogFavoritesProvider = LocalCatalogFavoritesProviderImpl(
                database: resolver.resolve(DatabaseService.self)!
            )

            let provider = CatalogItemsProviderImpl(
                catalogSourceClientFactory: catalogSourceClientFactory,
                localCatalogFavoritesProvider: localCatalogFavoritesProvider
            )

            return CatalogClientImpl(
                provider: provider,
                host: host,
                port: port
            )
        }

        container
            .register(CatalogClient.self, factory: factory)
            .inObjectScope(.transient)
    }
}

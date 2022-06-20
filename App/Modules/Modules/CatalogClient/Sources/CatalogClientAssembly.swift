import Swinject

public struct CatalogClientAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {

        let factory: (Resolver, String, Int) -> CatalogClient = { resolver, host, port in
            let catalogSourceClientFactory = CatalogSourceClientFactoryImpl()

            let provider = CatalogItemsProviderImpl(
                catalogSourceClientFactory: catalogSourceClientFactory
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

import Swinject

public struct CatalogClientAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container
            .register(CatalogClient.self) { resolver, host, port in
                CatalogClientImpl(
                    provider: CatalogItemsProviderImpl(),
                    host: host,
                    port: port
                )
            }
            .inObjectScope(.transient)
    }
}

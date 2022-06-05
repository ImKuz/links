import Swinject
import Database
import IPAddressProvider

public struct CatalogServerAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(CatalogServer.self) { resolver in
            guard
                let database = resolver.resolve(DatabaseService.self),
                let ipAddressProvider = resolver.resolve(IPAddressProvider.self)
            else {
                fatalError("Unable to register \(CatalogServer.self)!")
            }

            return CatalogServerImpl(
                database: database,
                ipAddressProvider: ipAddressProvider
            )
        }
    }
}

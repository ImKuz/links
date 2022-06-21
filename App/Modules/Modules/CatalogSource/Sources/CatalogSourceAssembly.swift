import Swinject
import CatalogClient
import Database
import SharedInterfaces
import Foundation

public struct CatalogSourceAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        registerLocalSource(container: container)
        registerRemoteSource(container: container)
    }
}

private extension CatalogSourceAssembly {

    func registerHelpers(container: Container) {
        container.register(FavoritesCatalogSourceHelper.self) { resolver in
            let database = resolver.resolve(DatabaseService.self)!
            return FavoritesCatalogSourceHelperImpl(databaseService: database)
        }
    }
    
    func registerLocalSource(container: Container) {
        let factory: (Resolver, NSPredicate?) -> CatalogSource = { resolver, topLevelPredicate in
            let databaseService = resolver.resolve(DatabaseService.self)!
            let helper = resolver.resolve(FavoritesCatalogSourceHelper.self)!

            return DatabaseCatalogSource(
                databaseService: databaseService,
                topLevelPredicate: topLevelPredicate,
                favoritesCatalogSourceHelper: helper
            )
        }

        container
            .register(CatalogSource.self, name: "local", factory: factory)
            .inObjectScope(.transient)
    }

    func registerRemoteSource(container: Container) {
        let factory: (Resolver, String, Int) -> CatalogSource = { resolver, host, port in
            let client = resolver.resolve(CatalogClient.self, arguments: host, port)!
            let helper = resolver.resolve(FavoritesCatalogSourceHelper.self)!

            return RemoteCatalogSource(
                client: client,
                favoritesCatalogSourceHelper: helper
            )
        }

        container
            .register(CatalogSource.self, name: "remote", factory: factory)
            .inObjectScope(.transient)
    }
}

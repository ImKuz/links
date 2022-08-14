import Swinject
import CatalogClient
import Database
import Foundation
import Models

public struct CatalogSourceAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        registerHelpers(container: container)
        registerLocalSource(container: container)
        registerRemoteSource(container: container)
    }
}

private extension CatalogSourceAssembly {

    func registerHelpers(container: Container) {
        container
            .register(FavoritesCatalogSourceHelper.self) { resolver in
                let database = resolver.resolve(DatabaseService.self)!
                return FavoritesCatalogSourceHelperImpl(databaseService: database)
            }
            .inObjectScope(.transient)

        container
            .register(RemoteCatalogSourceDatabaseBus.self) { resolver in
                let database = resolver.resolve(DatabaseService.self)!
                return RemoteCatalogSourceDatabaseBusImpl(databaseService: database)
            }
            .inObjectScope(.transient)
    }
    
    func registerLocalSource(container: Container) {
        let factory: (Resolver, CatalogSourceConfig) -> CatalogSource = { resolver, config in
            let databaseService = resolver.resolve(DatabaseService.self)!
            let helper = resolver.resolve(FavoritesCatalogSourceHelper.self)!

            guard case let .local(localConfig) = config.typeConfig else {
                fatalError("CatalogSource resolved with uncompatible config")
            }

            return DatabaseCatalogSource(
                databaseService: databaseService,
                favoritesCatalogSourceHelper: helper,
                topLevelPredicate: localConfig.topLevelPredicate,
                overridingPermissions: config.permissionsOverride
            )
        }

        container
            .register(CatalogSource.self, name: "local", factory: factory)
            .inObjectScope(.transient)
    }

    func registerRemoteSource(container: Container) {
        let factory: (Resolver, CatalogSourceConfig) -> CatalogSource = { resolver, config in

            guard case let .remote(remoteConfig) = config.typeConfig else {
                fatalError("CatalogSource resolved with uncompatible config")
            }

            let client = resolver.resolve(CatalogClient.self, arguments: remoteConfig.host, remoteConfig.port)!
            let helper = resolver.resolve(FavoritesCatalogSourceHelper.self)!
            let bus = resolver.resolve(RemoteCatalogSourceDatabaseBus.self)!

            return RemoteCatalogSource(
                client: client,
                favoritesCatalogSourceHelper: helper,
                bus: bus
            )
        }

        container
            .register(CatalogSource.self, name: "remote", factory: factory)
            .inObjectScope(.transient)
    }
}

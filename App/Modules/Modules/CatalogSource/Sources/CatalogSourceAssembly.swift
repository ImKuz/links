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
    
    func registerLocalSource(container: Container) {
        let factory: (Resolver, NSPredicate?) -> CatalogSource = { resolver, topLevelPredicate in
            let databaseService = resolver.resolve(DatabaseService.self)!

            return DatabaseCatalogSource(
                databaseService: databaseService,
                topLevelPredicate: topLevelPredicate
            )
        }

        container
            .register(CatalogSource.self, name: "local", factory: factory)
            .inObjectScope(.transient)
    }

    func registerRemoteSource(container: Container) {
        let factory: (Resolver, String, Int) -> CatalogSource = { resolver, host, port in
            let client = resolver.resolve(CatalogClient.self, arguments: host, port)!
            return RemoteCatalogSource(client: client)
        }

        container
            .register(CatalogSource.self, name: "remote", factory: factory)
            .inObjectScope(.transient)
    }
}

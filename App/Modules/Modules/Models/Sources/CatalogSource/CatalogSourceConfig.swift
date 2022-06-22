import Foundation

public struct CatalogSourceConfig {

    public let permissionsOverride: CatalogDataSourcePermissions?
    public let typeConfig: CatalogSourceConfigTypeConfig

    public init(
        permissionsOverride: CatalogDataSourcePermissions?,
        typeConfig: CatalogSourceConfigTypeConfig
    ) {
        self.permissionsOverride = permissionsOverride
        self.typeConfig = typeConfig
    }
}

public struct LocalCatalogSourceConfig {

    public let topLevelPredicate: NSPredicate?

    public init(topLevelPredicate: NSPredicate?) {
        self.topLevelPredicate = topLevelPredicate
    }
}

public struct RemoteCatalogSourceConfig {

    public let host: String
    public let port: Int

    public init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
}

public enum CatalogSourceConfigTypeConfig {
    case local(LocalCatalogSourceConfig)
    case remote(RemoteCatalogSourceConfig)
}

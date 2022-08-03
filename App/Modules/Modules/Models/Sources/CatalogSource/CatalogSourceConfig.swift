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

public typealias RemoteCatalogSourceConfig = ServerCredentials

public enum CatalogSourceConfigTypeConfig {
    case local(LocalCatalogSourceConfig)
    case remote(RemoteCatalogSourceConfig)
}

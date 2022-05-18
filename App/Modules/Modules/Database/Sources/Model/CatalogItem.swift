import ToolKit

public struct CatalogItem: PersistableEntity {

    public typealias ModelObject = CatalogItemEntity

    public let storeId: String
    public let itemId: String
    public let name: String?
    public let content: String
    public let contentType: String
    public let isFavorite: Bool
    public var index: Int16
    public let remoteServerId: String?

    public init(
        storeId: String,
        itemId: String,
        name: String?,
        content: String,
        contentType: String,
        isFavorite: Bool,
        index: Int16,
        remoteServerId: String?
    ) {
        self.storeId = storeId
        self.itemId = itemId
        self.name = name
        self.content = content
        self.contentType = contentType
        self.isFavorite = isFavorite
        self.index = index
        self.remoteServerId = remoteServerId
    }

    public init?(object: ModelObject) {
        guard
            let storeId = object.storeId,
            let itemId = object.itemId,
            let content = object.content,
            let contentType = object.contentType
        else { return nil }

        self.storeId = storeId
        self.itemId = itemId
        self.name = object.name
        self.content = content
        self.contentType = contentType
        self.isFavorite = object.isFavorite
        self.index = object.index
        self.remoteServerId = object.remoteServerId
    }

    public func convertProperties(object: ModelObject) {
        object.storeId = storeId
        object.itemId = itemId
        object.name = name
        object.content = content
        object.contentType = contentType
        object.isFavorite = isFavorite
        object.index = index
        object.remoteServerId = remoteServerId
    }
}

extension CatalogItem: Identifiable {
    public var id: String { itemId }
}

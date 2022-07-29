import ToolKit
import Foundation

public class CatalogItem: PersistableEntity {

    public typealias ModelObject = CatalogItemEntity
    public typealias Params = [String: String]

    // MARK: - Properties

    public let storeId: String
    public let itemId: String
    public let name: String?
    public let content: String
    public let contentType: String
    public var isFavorite: Bool
    public var index: Int16
    public let remoteServerId: String?
    public let params: Params

    // MARK: - Init

    public init(
        storeId: String,
        itemId: String,
        name: String?,
        content: String,
        contentType: String,
        isFavorite: Bool,
        index: Int16,
        remoteServerId: String?,
        params: Params
    ) {
        self.storeId = storeId
        self.itemId = itemId
        self.name = name
        self.content = content
        self.contentType = contentType
        self.isFavorite = isFavorite
        self.index = index
        self.remoteServerId = remoteServerId
        self.params = params
    }

    required public init?(object: ModelObject) {
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
        self.params = Self.decodeParams(object.params)
    }

    // MARK: - Public methods

    public func convertProperties(object: ModelObject) {
        object.storeId = storeId
        object.itemId = itemId
        object.name = name
        object.content = content
        object.contentType = contentType
        object.isFavorite = isFavorite
        object.index = index
        object.remoteServerId = remoteServerId
        object.params = encodeParams()
    }

    // MARK: - Private methods

    private func encodeParams() -> Data? {
        guard !params.isEmpty else { return nil }

        return try? JSONEncoder().encode(params)
    }

    private static func decodeParams(_ data: Data?) -> [String: String] {
        guard let data = data else { return [:] }

        return (try? JSONDecoder().decode(Params.self, from: data)) ?? [:]
    }
}

extension CatalogItem: Identifiable {
    public var id: String { itemId }
}

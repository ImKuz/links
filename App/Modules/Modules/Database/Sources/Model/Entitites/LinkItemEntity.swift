import ToolKit
import Foundation

public class LinkItemEntity: PersistableEntity {

    public typealias ModelObject = LinkItemObject

    // MARK: - Properties

    public let storeId: String
    public let itemId: String

    public var name: String
    public var urlString: String
    public var index: Int16
    public var isFavorite: Bool

    // MARK: - Init

    public init(
        storeId: String,
        itemId: String,
        name: String,
        urlString: String,
        index: Int16,
        isFavorite: Bool
    ) {
        self.storeId = storeId
        self.itemId = itemId
        self.name = name
        self.urlString = urlString
        self.index = index
        self.isFavorite = isFavorite
    }

    required public init?(object: ModelObject) {
        guard
            let storeId = object.storeId,
            let itemId = object.itemId,
            let name = object.name,
            let urlString = object.urlString
        else {
            return nil
        }

        self.storeId = storeId
        self.itemId = itemId
        self.name = name
        self.urlString = urlString

        self.index = object.index
        self.isFavorite = object.isFavorite
    }

    // MARK: - Public methods

    public func convertProperties(object: ModelObject) {
        object.storeId = storeId
        object.itemId = itemId
        object.name = name
        object.urlString = urlString
        object.index = index
        object.isFavorite = isFavorite
    }
}

extension LinkItemEntity: Identifiable {

    public var id: String { itemId }
}

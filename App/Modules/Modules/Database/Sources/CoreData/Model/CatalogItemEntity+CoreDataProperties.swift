import Foundation
import CoreData

extension CatalogItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CatalogItemEntity> {
        return NSFetchRequest<CatalogItemEntity>(entityName: "CatalogItemEntity")
    }

    @NSManaged public var content: String?
    @NSManaged public var contentType: String?
    @NSManaged public var index: Int16
    @NSManaged public var isFavorite: Bool
    @NSManaged public var itemId: String?
    @NSManaged public var name: String?
    @NSManaged public var remoteServerId: String?
    @NSManaged public var storeId: String?
    @NSManaged public var params: Data?

}

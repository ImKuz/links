import Foundation
import CoreData


extension LinkItemObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LinkItemObject> {
        return NSFetchRequest<LinkItemObject>(entityName: "LinkItemObject")
    }

    @NSManaged public var urlString: String?
    @NSManaged public var index: Int16
    @NSManaged public var isFavorite: Bool
    @NSManaged public var itemId: String?
    @NSManaged public var name: String?
    @NSManaged public var storeId: String?

}

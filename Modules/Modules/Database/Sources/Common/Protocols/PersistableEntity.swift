import CoreData

public protocol PersistableEntity {

    var storeId: String { get }

    associatedtype ModelObject: NSManagedObject

    func convertProperties(object: ModelObject)
    func convertRelations(object: ModelObject, context: Context)

    init?(object: ModelObject)
}

public extension PersistableEntity {

    func convertRelations(object: ModelObject, context: Context) {}
}

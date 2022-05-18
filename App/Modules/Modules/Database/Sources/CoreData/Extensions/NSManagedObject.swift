import CoreData

extension NSManagedObject {

    open class var entityName: String {
        NSStringFromClass(self).components(separatedBy: ".").last!
    }
}

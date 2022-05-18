import CoreData
import Foundation

extension NSManagedObjectModel {

    static func managedObjectModel(forResource resource: String, inModel modelName: String) -> NSManagedObjectModel? {
        let bundle = Bundle.main
        let subdirectory = modelName + ".momd"

        guard let url = bundle.url(forResource: resource, withExtension: "mom", subdirectory: subdirectory) else {
            assertionFailure("Unable to find model in bundle")
            return nil
        }

        guard let model = NSManagedObjectModel(contentsOf: url) else {
            assertionFailure("Unable to load model in bundle")
            return nil
        }

        return model
    }
}

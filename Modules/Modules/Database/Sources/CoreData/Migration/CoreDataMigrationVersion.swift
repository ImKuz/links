import CoreData
import Foundation

enum CoreDataMigrationVersion: Int, CaseIterable {
    case v1 = 1

    static var current: CoreDataMigrationVersion {
        guard let latest = allCases.last else {
            fatalError("no model versions found")
        }

        return latest
    }

    var modelName: String {
        let name = CoreDataConst.modelName
        guard rawValue > 1 else { return name }
        return name + "V\(rawValue)"
    }

    func nextVersion() -> CoreDataMigrationVersion? {
        let all = Self.allCases
        guard let index = all.firstIndex(of: self), index + 1 < all.count else { return nil }
        return all[index + 1]
    }
}

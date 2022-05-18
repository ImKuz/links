# Database

Package for work with CoreData stack

# Usage example

```
    let db: DatabaseService
    
    func writeSync() throws {
        try db.wrtieSync { context in
            try context.create(user)
            try context.save()
        }
    }
    
    func writeAsync(_ completion: @escaping (Result<Void, Error>) -> Void) {
        db.wrtieAsync(completion: completion) { context in
            try context.create(users)
            try context.save()
        } 
    }
    
    func read() -> [User] throws {
        try db.fetchSync(User.self)
    }
    
    func read(_ completion: (Result<[User], Error>) -> Void) {
        var request = FetchRequest()
        request.apply(.filter(keyPath: \User.ModelObject.name, equalTo: "John"))
        
        db.fetchAsync(
            User.self, 
            request: request, 
            completion: completion
        )
    }
}
```
# Models

In order to create new model, perform the following steps:

1) Create entity in `.xcdatamodel` scheme
2) Manually generate `NSManagedObject` subclass using Xcode (With `.xcdatamodel` selected, Editor ->  Create NSManagedObject subclass)
3) Put generated files in Database/CoreData/Models directory
4) Make any required models conforming PersistableEntity protocol with required conversions to newly created NSManagedObject subclass.

It is important to note that every entity should have `storeId` property even if your model is not unique. It is needed to support model conversions.
It is preffered to never edit generated model but simply replace them with newly created to avoid human errors.

# Migration process

The framework use progressive migrations in order to simplify model migrations over multiple versions
We use the following material as the foundation: https://williamboles.me/progressive-core-data-migration/
It is strongly recommended to check out before proceeding.

Steps required to migrate store (e.g. from version 2 to version 3): 
1) Create new `.xcdatamodel` version named `CoreDataModelV3` (with `.xcdatamodel` selected, Editor -> Add model version)
2) Create corresponding `.xcmappingmodel` mapping model with name `CoreDataMapping2to3`
    The scheme will automatically map values. If some properties renamed, you may map them here.
    Mapping models should be stored in StoryMe/CoreData/Mappings
3) (Optional) If changes requires code to map values (e.g. splitting model into two) you need to create migration policy
    Migration policies should be stored in StoryMe/CoreData/MigrationPolicies
```
final class User2ToUser3MigrationPolicy: NSEntityMigrationPolicy {
    
    override func createDestinationInstances(
        forSource sourceInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        try super.createDestinationInstances(
            forSource: sourceInstance,
            in: mapping,
            manager: manager
        )

        guard
            let destinationModel = manager.destinationInstances(
                forEntityMappingName: mapping.name,
                sourceInstances: [sourceInstance]
            ).first as? User,
            let sourceModel = sourceInstance as? User
        else {
            fatalError("was expected a model")
        }

        let fullName = "\(sourceModel.firstname) \(sourceModel.surname)"

        destinationModel.setValue(fullName, forKey: "fullName")
    }
}
```
4) Increase model version in `CoreDataMigrationVersion.swift`
```
enum CoreDataMigrationVersion: Int, CaseIterable {
    case v1 = 1, v2, v3
```
5) Generate NSManagedObject subclass for changed enitites and replace the old ones

# NSPredicate

The package provides useful extensions for `NSPredicate` use. 

```
// Comparsions
NSPredicate.filter(keyPath: \User.ModelObject.age, equalTo: 42)
NSPredicate.filter(keyPath: \User.ModelObject.name, equalTo: "John")

// Compounding by AND
NSPredicate.compound(
    .filter(keyPath: \User.ModelObject.age, moreThan: 30),
    .filter(keyPath: \User.ModelObject.department, value: "dev-", operator: .beginsWith)
)

// Reverse logic condition
NSPredicate.not(.filter(keyPath: \User.ModelObject.tag, in: ["tag1", "tag2"]))
```

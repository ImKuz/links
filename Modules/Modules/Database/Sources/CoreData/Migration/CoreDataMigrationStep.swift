import CoreData

struct CoreDataMigrationStep {

    let sourceModel: NSManagedObjectModel
    let destinationModel: NSManagedObjectModel
    let mappingModel: NSMappingModel

    // MARK: - Lifecycle

    init?(sourceVersion: CoreDataMigrationVersion, destinationVersion: CoreDataMigrationVersion) {
        let baseModelName = CoreDataConst.modelName

        guard
            let sourceModel = NSManagedObjectModel.managedObjectModel(
                forResource: sourceVersion.modelName,
                inModel: baseModelName
            ),
            let destinationModel = NSManagedObjectModel.managedObjectModel(
                forResource: destinationVersion.modelName,
                inModel: baseModelName
            )
        else {
            assertionFailure("Expected object model not present")
            return nil
        }

        guard
            let mappingModel = CoreDataMigrationStep.mappingModel(
                fromSourceModel: sourceModel,
                toDestinationModel: destinationModel
            )
        else {
            assertionFailure("Expected mapping model not present")
            return nil
        }

        self.sourceModel = sourceModel
        self.destinationModel = destinationModel
        self.mappingModel = mappingModel
    }

    // MARK: - Mapping

    private static func mappingModel(
        fromSourceModel sourceModel: NSManagedObjectModel,
        toDestinationModel destinationModel: NSManagedObjectModel
    ) -> NSMappingModel? {
        guard
            let customMapping = customMappingModel(
                fromSourceModel: sourceModel,
                toDestinationModel: destinationModel
            )
        else {
            return try? .inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel)
        }

        return customMapping
    }

    private static func customMappingModel(
        fromSourceModel sourceModel: NSManagedObjectModel,
        toDestinationModel destinationModel: NSManagedObjectModel
    ) -> NSMappingModel? {
        NSMappingModel(
            from: [Bundle.main],
            forSourceModel: sourceModel,
            destinationModel: destinationModel
        )
    }
}

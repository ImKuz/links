import CoreData

extension NSManagedObjectContext: Context {

    enum Key {
        static let storeId = "storeId"
    }

    // MARK: - Context

    public func create<Entity: PersistableEntity>(_ entities: [Entity]) throws {
        entities.forEach { entity in
            let object = Entity.ModelObject(context: self)
            entity.convertProperties(object: object)
            entity.convertRelations(object: object, context: self)
        }
    }

    public func read<Entity: PersistableEntity>(type: Entity.Type, request: FetchRequest) throws -> [Entity] {
        try fetchObjects(type: Entity.ModelObject.self, request: request).compactMap { Entity(object: $0) }
    }

    public func update<Entity: PersistableEntity>(_ entities: [Entity]) throws {
        let objects = try fetchCorrespondingObjects(forEntities: entities)

        let idsMap = objects.reduce(into: [String: Entity.ModelObject]()) { map, object in
            guard let id = object.value(forKey: Key.storeId) as? String else { return }
            map[id] = object
        }

        entities.forEach {
            guard let object = idsMap[$0.storeId] else { return }
            $0.convertProperties(object: object)
            $0.convertRelations(object: object, context: self)
        }
    }

    public func delete<Entity: PersistableEntity>(_ entities: [Entity]) throws {
        try fetchCorrespondingObjects(forEntities: entities).forEach { delete($0) }

    }

    public func discard() {
        rollback()
    }

    // MARK: - Private methods

    private func fetchCorrespondingObjects<Entity: PersistableEntity>(
        forEntities entities: [Entity]
    ) throws -> [Entity.ModelObject] {
        let request = FetchRequest(
            predicate: .init(
                format: "\(Key.storeId) IN %@",
                entities.map(\.storeId)
            )
        )
        return try fetchObjects(type: Entity.ModelObject.self, request: request)
    }

    private func fetchObjects<Object: NSManagedObject>(type: Object.Type, request: FetchRequest) throws -> [Object] {
        let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Object.entityName)
        fetchRequest.predicate = request.predicate
        fetchRequest.sortDescriptors = request.sortDescriptor.map { [$0] }
        fetchRequest.fetchOffset = request.fetchOffset
        fetchRequest.fetchLimit = request.fetchLimit

        return try fetch(fetchRequest).compactMap { $0 as? Object }
    }
}

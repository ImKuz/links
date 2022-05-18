public protocol Context {

    func create<Entity: PersistableEntity>(_ entity: Entity) throws
    func create<Entity: PersistableEntity>(_ entities: [Entity]) throws
    func read<Entity: PersistableEntity>(type: Entity.Type, request: FetchRequest) throws -> [Entity]
    func read<Entity: PersistableEntity>(type: Entity.Type) throws -> [Entity]
    func update<Entity: PersistableEntity>(_ entity: Entity) throws
    func update<Entity: PersistableEntity>(_ entities: [Entity]) throws
    func delete<Entity: PersistableEntity>(_ entities: [Entity]) throws
    func delete<Entity: PersistableEntity>(_ entity: Entity) throws

    func save() throws
    func discard()
}

public extension Context {

    func create<Entity: PersistableEntity>(_ entity: Entity) throws {
        try create([entity])
    }

    func read<Entity: PersistableEntity>(type: Entity.Type) throws -> [Entity] {
        try read(type: type.self, request: FetchRequest())
    }

    func update<Entity: PersistableEntity>(_ entity: Entity) throws {
        try update([entity])
    }

    func delete<Entity: PersistableEntity>(_ entity: Entity) throws {
        try delete([entity])
    }
}

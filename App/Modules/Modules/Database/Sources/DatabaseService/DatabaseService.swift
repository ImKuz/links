import Combine

public protocol DatabaseService: AnyObject {

    var contentUpdatePublisher: AnyPublisher<Void, Never> { get }

    func write(operation: @escaping (Context) throws -> Void) -> AnyPublisher<Void, Error>

    func fetchAsync<Entity>(
        _ type: Entity.Type,
        request: FetchRequest
    ) -> AnyPublisher<[Entity], Error>
    where Entity: PersistableEntity

    func deleteAll<Entity: PersistableEntity>(type: Entity.Type) -> AnyPublisher<Void, Error>
}

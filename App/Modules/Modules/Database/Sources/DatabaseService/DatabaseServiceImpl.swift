import Foundation
import Combine

final public class DatabaseServiceImpl: DatabaseService {

    // MARK: - Private properties

    private let storage: Storage
    private let contentUpdateSubject = PassthroughSubject<Void, Never>()

    // MARK: - Public properties

    public var contentUpdatePublisher: AnyPublisher<Void, Never> {
        contentUpdateSubject
            .share()
            .eraseToAnyPublisher()
    }

    // MARK: - Lifecycle

    init(storage: Storage) {
        self.storage = storage
    }

    // IMPORTANT: Do not remove this deinit, absence of this deinit causes crash
    deinit {}

    // MARK: - Public methods

    public func write(operation: @escaping (Context) throws -> Void) -> AnyPublisher<Void, Error> {
        storage
            .write(operation: operation)
            .handleEvents(receiveOutput: { [weak contentUpdateSubject] in
                contentUpdateSubject?.send(())
            })
            .eraseToAnyPublisher()
    }

    public func fetch<Entity>(
        _ type: Entity.Type,
        request: FetchRequest
    ) -> AnyPublisher<[Entity], Error>
    where Entity: PersistableEntity {
        storage.fetch(type, request: request)
    }

    public func deleteAll<Entity: PersistableEntity>(type: Entity.Type) -> AnyPublisher<Void, Error> {
        write { context in
            let objects = try context.read(type: type.self)
            try context.delete(objects)
            try context.save()
        }
    }
}

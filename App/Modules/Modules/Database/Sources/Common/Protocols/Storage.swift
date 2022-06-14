import Foundation
import Combine

protocol Storage {

    func write(operation: @escaping (Context) throws -> Void) -> AnyPublisher<Void, Error>

    func fetchAsync<Entity>(
        _ type: Entity.Type,
        request: FetchRequest
    ) -> AnyPublisher<[Entity], Error>
    where Entity: PersistableEntity
}

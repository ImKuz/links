import Foundation
import Combine

protocol Storage {

    func write(operation: @escaping (Context) throws -> Void) -> AnyPublisher<Void, Error>

    func fetch<Entity>(
        _ type: Entity.Type,
        request: FetchRequest
    ) -> AnyPublisher<[Entity], Error>
    where Entity: PersistableEntity
}

import CoreData
import Foundation
import Combine

public protocol DatabaseService {

    var contentUpdatePublisher: AnyPublisher<Void, Never> { get }

    func writeSync(_ operation: @escaping (Context) throws -> Void) throws

    func writeAsync(
        _ operation: @escaping (Context) throws -> Void,
        completion: ((Result<Void, Error>) -> Void)?
    )

    func fetchSync<Entity>(
        _ type: Entity.Type,
        inMainThread: Bool,
        request: FetchRequest
    ) throws -> [Entity] where Entity: PersistableEntity

    func fetchAsync<Entity>(
        _ type: Entity.Type,
        request: FetchRequest,
        completion: ((Result<[Entity], Error>) -> Void)?
    ) where Entity: PersistableEntity

    func deleteAll<Entity: PersistableEntity>(type: Entity.Type) throws

}

final public class DatabaseServiceImpl: DatabaseService {

    // MARK: - Const

    private enum Const {
        static let storeSubpath = "persistentStore"
    }

    // MARK: - Private properties

    private let storage: CoreDataStorage
    private let contentUpdateSubject = PassthroughSubject<Void, Never>()

    // MARK: - Public properties

    public var contentUpdatePublisher: AnyPublisher<Void, Never> {
        contentUpdateSubject
            .share()
            .eraseToAnyPublisher()
    }

    // MARK: - Lifecycle

    public init() throws {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = true

        var storeUrl = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        storeUrl.appendPathComponent(Const.storeSubpath, isDirectory: true)

        if !fileManager.fileExists(atPath: storeUrl.path, isDirectory: &isDirectory) {
            try fileManager.createDirectory(
                at: storeUrl,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        storage = try CoreDataStorage(storeURL: storeUrl)
    }

    // IMPORTANT: Do not remove this deinit, absence of this deinit causes crash
    deinit {}

    // MARK: - Public methods

    /// Synchronously writes data on disc. Errors thrown in Context will be rethrown in this method.
    public func writeSync(_ operation: @escaping (Context) throws -> Void) throws {
        try storage.writeSync(operation: operation)
        contentUpdateSubject.send()
    }

    /// Asynchronously writes data on disc. Errors thrown in Context will not be rethrown in this method.
    public func writeAsync(
        _ operation: @escaping (Context) throws -> Void,
        completion: ((Result<Void, Error>) -> Void)?
    ) {
        storage.writeAsync(operation: operation) { [weak self] in
            self?.contentUpdateSubject.send()
            completion($0)
        }
    }

    /// Fetches `PersistableEntity` array using fetch parameters defined in `FetchRequest`
    /// - Parameters:
    ///   - inMainThread: Flag defining should we use read context or not,
    ///   if flag set to `true` and method called in non-main thread, exception will be thrown
    public func fetchSync<Entity>(
        _ type: Entity.Type,
        inMainThread: Bool,
        request: FetchRequest = FetchRequest()
    ) throws -> [Entity] where Entity: PersistableEntity {
        try storage.fetchSync(
            type.self,
            inMainThread: inMainThread,
            request: request
        )
    }

    public func fetchAsync<Entity>(
        _ type: Entity.Type,
        request: FetchRequest = FetchRequest(),
        completion: ((Result<[Entity], Error>) -> Void)?
    ) where Entity: PersistableEntity {
        storage.fetchAsync(
            type,
            request: request,
            completion: completion
        )
    }

    /// Deletes all entities of defined type
    public func deleteAll<Entity: PersistableEntity>(type: Entity.Type) throws {
        try storage.writeSync { context in
            let objects = try context.read(type: type.self)
            try context.delete(objects)
        }
    }
}

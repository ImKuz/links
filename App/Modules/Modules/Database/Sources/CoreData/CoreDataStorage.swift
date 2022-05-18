import CoreData
import Foundation

final class CoreDataStorage {

    private let container: NSPersistentContainer
    private let migrator = CoreDataMigrator()
    private var isLoaded = false

    private let backgroundQueue = DispatchQueue(
        label: "tech.polysander.CopyPasta.db-back-q",
        qos: .background,
        attributes: .concurrent
    )

    private var readContext: NSManagedObjectContext { container.viewContext }
    private lazy var writeContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        return context
    }()

    // MARK: - Lifecycle

    init(storeURL: URL) throws {
        container = try PersistentStoreFactory.create(path: storeURL)
        migrateStoreIfNeeded { [self] result in
            switch result {
            case .success:
                isLoaded = true
                loadStore()
            case .failure(let error):
                assertionFailure(error.localizedDescription)
            }
        }
    }

    // MARK: - Public methods

    func writeSync(operation: @escaping (Context) throws -> Void) throws {
        try checkLoadingState()
        var writeError: Error?

        try backgroundQueue.sync {
            writeContext.performAndWait {
                do {
                    try operation(writeContext)
                } catch {
                    writeError = error
                }
            }

            if let writeError = writeError {
                throw writeError
            }
        }
    }

    func writeAsync(
        operation: @escaping (Context) throws -> Void,
        completion: ((Result<Void, Error>) -> Void)?
    ) {
        guard isLoaded else {
            let error = DatabaseError(
                code: .unableToWrite,
                description: "Attemped to wirte while store is not loaded"
            )

            assertionFailure(error.description)
            completion?(.failure(error))
            return
        }

        backgroundQueue.async {
            self.writeContext.perform { [self] in
                do {
                    try operation(writeContext)
                    completion?(.success(()))
                } catch {
                    assertionFailure("Unable to write: \n \(error.localizedDescription)")
                    completion?(.failure(error))
                }
            }
        }
    }

    func fetchSync<Entity>(
        _ type: Entity.Type,
        inMainThread: Bool,
        request: FetchRequest
    ) throws -> [Entity] where Entity: PersistableEntity {
        if inMainThread && !Thread.isMainThread {
            let description = "Called main thread fetch in non-main thread"
            assertionFailure(description)
            throw DatabaseError(code: .common, description: description)
        }

        try checkLoadingState()

        if inMainThread {
            return try readContext.read(type: Entity.self, request: request)
        } else {
            return try backgroundQueue.sync {
                try writeContext.read(type: Entity.self, request: request)
            }
        }
    }

    func fetchAsync<Entity>(
        _ type: Entity.Type,
        request: FetchRequest,
        completion: ((Result<[Entity], Error>) -> Void)?
    ) where Entity: PersistableEntity {
        do {
            try checkLoadingState()
            return backgroundQueue.async {
                do {
                    let result = try self.writeContext.read(type: Entity.self, request: request)
                    completion?(.success(result))
                } catch {
                    completion?(.failure(error))
                }
            }
        } catch {
            completion?(.failure(error))
        }
    }

    // MARK: - Private methods

    private func checkLoadingState() throws {
        guard isLoaded else {
            throw DatabaseError(
                code: .common,
                description: "Attemped to access while store is not loaded"
            )
        }
    }

    private func loadStore() {
        container.loadPersistentStores { _, error in
            if let error = error {
                assertionFailure("Unable to load store: \n \(error.localizedDescription)")
            }
        }
    }

    private func migrateStoreIfNeeded(_ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let storeURL = container.persistentStoreDescriptions.first?.url else {
            let description = "PersistentContainer was not set up properly"
            assertionFailure(description)
            let error = DatabaseError(code: .unableToLoad, description: description)
            completion(.failure(error))
            return
        }

        if migrator.requiresMigration(at: storeURL, toVersion: CoreDataMigrationVersion.current) {
            DispatchQueue.global(qos: .userInitiated).sync {
                do {
                    try self.migrator.migrateStore(at: storeURL, toVersion: CoreDataMigrationVersion.current)
                } catch {
                    completion(.failure(error))
                }
                completion(.success(()))
            }
        } else {
            completion(.success(()))
        }
    }
}

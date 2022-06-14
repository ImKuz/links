import CoreData
import Foundation
import Combine

final class CoreDataStorage {

    private enum Spec {
        static let storeSubpath = "persistentStore"
    }

    // MARK: - Private properties

    private let container: NSPersistentContainer
    private let migrator = CoreDataMigrator()
    private var isLoaded = false

    private let backgroundQueue = DispatchQueue(
        label: "com.copy-pasta.db-back-q",
        qos: .background,
        attributes: .concurrent
    )

    private var readContext: NSManagedObjectContext { container.viewContext }
    
    private lazy var writeContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        return context
    }()

    // MARK: - Init

    init(fileManager: FileManager) throws {
        var isDirectory: ObjCBool = true

        var storeUrl = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        storeUrl.appendPathComponent(Spec.storeSubpath, isDirectory: true)

        if !fileManager.fileExists(atPath: storeUrl.path, isDirectory: &isDirectory) {
            try fileManager.createDirectory(
                at: storeUrl,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        container = try PersistentStoreFactory.create(path: storeUrl)

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

// MARK: - Storage

extension CoreDataStorage: Storage {

    func write(operation: @escaping (Context) throws -> Void) -> AnyPublisher<Void, Error> {
        guard isLoaded else {
            let error = DatabaseError(
                code: .unableToWrite,
                description: "Attemped to wirte while store is not loaded"
            )

            assertionFailure(error.description)
            return Fail(error: error).eraseToAnyPublisher()
        }

        return Deferred {
            Future { [weak self] promise in
                guard let self = self else { return }

                self.writeContext.perform { [writeContext = self.writeContext] in
                    do {
                        try operation(writeContext)
                        promise(.success(()))
                    } catch {
                        assertionFailure("Unable to write: \n \(error.localizedDescription)")
                        promise(.failure(error))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
        .subscribe(on: backgroundQueue)
        .eraseToAnyPublisher()
    }

    func fetchAsync<Entity>(
        _ type: Entity.Type,
        request: FetchRequest
    ) -> AnyPublisher<[Entity], Error>
    where Entity: PersistableEntity {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else { return }

                do {
                    try self.checkLoadingState()
                    let result = try self.writeContext.read(type: Entity.self, request: request)
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }.eraseToAnyPublisher()
        }
        .subscribe(on: backgroundQueue)
        .eraseToAnyPublisher()
    }
}

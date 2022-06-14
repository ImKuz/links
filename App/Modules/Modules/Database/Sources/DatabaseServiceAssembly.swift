import Swinject

public struct DatabaseServiceAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(DatabaseService.self) { _ in
            do {
                let storage = try CoreDataStorage(fileManager: .default)
                return DatabaseServiceImpl(storage: storage)
            } catch {
                fatalError("Unable to assemble DatabaseService\nreason: \(error.localizedDescription)")
            }
        }
    }
}

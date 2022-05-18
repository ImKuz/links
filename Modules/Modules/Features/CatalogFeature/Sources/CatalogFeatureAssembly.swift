import Database
import Swinject
import SharedEnv
import SharedInterfaces

public struct CatalogFeatureAssembly: Assembly {

    private let container: Container

    public init(container: Container) {
        self.container = container
    }

    // MARK: - Public methods

    public func assemble(container: Container) {
        // MARK: - Local data source
        container.register(CatalogViewHolder.self, name: "local") { resolver in
            let databaseService = resolver.resolve(DatabaseService.self)!
            let source = DatabaseCatalogSource(databaseService: databaseService)

            return CatalogView(
                store: .init(
                    initialState: .initial,
                    reducer: CatalogReducerFactory().make(),
                    environment: SystemEnv.make(environment: CatalogEnvImpl(catalogSource: source))
                )
            )
        }
    }

    public static func previewMock() -> CatalogView {
        CatalogView(
            store: .init(
                initialState: .init(items: [
                    .init(name: "First", text: ""),
                    .init(name: "Second", text: ""),
                    .init(name: "Third", text: "")
                ]),
                reducer: CatalogReducerFactory().make(),
                environment: SystemEnv.make(environment: CatalogEnvImpl(catalogSource: CatalogSourceMock()))
            )
        )
    }
}

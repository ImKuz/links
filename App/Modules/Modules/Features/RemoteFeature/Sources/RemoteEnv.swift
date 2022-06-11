import ToolKit
import ComposableArchitecture
import Combine
import CatalogServer
import Swinject
import SharedInterfaces

final class RemoteEnvImpl: RemoteEnv {

    private let router: Router
    private let catalogServer: CatalogServer
    private let container: Container

    init(
        router: Router,
        catalogServer: CatalogServer,
        container: Container
    ) {
        self.router = router
        self.catalogServer = catalogServer
        self.container = container
    }

    func showServerView(isAnimated: Bool) {
        let view = ServerFeatueFactory.make(router: router, catalogServer: catalogServer) { [weak self] in
            self?.router.pop(isAnimated: true)
        }

        router.pushToView(view: view, isAnimated: isAnimated)
    }

    func showCatalog(host: String, port: Int) -> Effect<Void, Never> {
        let input = CatalogFeatureInterface.Input(router: router, credentials: (host, port))

        guard let interface = container.resolve(
            CatalogFeatureInterface.self,
            name: "remote",
            argument: input
        ) else {
            return .none
        }

        router.pushToView(viewController: interface.viewController, isAnimated: false)
        return Just(()).eraseToEffect()
    }

    func showConnectForm() -> Effect<(String, Int), Never> {
        Future<(String, Int), Never> { [weak self] promise in
            let form = ConnectFormFactory.make(
                onDone: { host, port in
                    self?.router.dismiss(isAnimated: true)
                    promise(.success((host, port)))
                },
                onCancel: {
                    self?.router.dismiss(isAnimated: true)
                }
            )

            self?.router.presentView(view: form)
        }
        .eraseToEffect()
    }
}

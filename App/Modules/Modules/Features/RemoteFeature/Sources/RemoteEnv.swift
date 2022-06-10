import ToolKit
import ComposableArchitecture
import Combine
import CatalogServer

final class RemoteEnvImpl: RemoteEnv {

    private let router: Router
    private let catalogServer: CatalogServer

    init(router: Router, catalogServer: CatalogServer) {
        self.router = router
        self.catalogServer = catalogServer
    }

    func showServerView(isAnimated: Bool) {
        let view = ServerFeatueFactory.make(router: router, catalogServer: catalogServer) { [weak self] in
            self?.router.pop(isAnimated: true)
        }

        router.pushToView(view: view, isAnimated: isAnimated)
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

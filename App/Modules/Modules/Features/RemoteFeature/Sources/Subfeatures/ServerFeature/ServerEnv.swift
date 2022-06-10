import ComposableArchitecture
import Combine
import ToolKit
import CatalogServer
import UIKit

final class ServerEnvImpl: ServerEnv {

    private let server: CatalogServer
    private let router: Router
    private let onClose: (() -> ())?

    init(
        server: CatalogServer,
        router: Router,
        onClose: (() -> ())?
    ) {
        self.server = server
        self.router = router
        self.onClose = onClose
    }

    func start(port: Int) -> Effect<(String, Int)?, AppError> {
        server
            .start(port: port)
            .mapError { _ in AppError.businessLogic("Unable to start server") }
            .eraseToEffect()
    }

    func stop() -> Effect<Void, AppError> {
        server
            .stop()
            .mapError { _ in AppError.businessLogic("Unable to stop server") }
            .eraseToEffect()
    }

    func showInfoAlert(title: String, message: String?) -> Effect<Void, Never> {

        let alertVC = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alertVC.addAction(
            .init(title: "OK", style: .cancel, handler: { _ in })
        )

        router.presentAlert(controller: alertVC)
        return .none
    }

    func close() {
        onClose?()
    }
}

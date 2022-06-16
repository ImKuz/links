import ToolKit
import ComposableArchitecture
import Combine
import CatalogServer
import Swinject
import SharedInterfaces
import Foundation
import Constants

final class RemoteEnvImpl: RemoteEnv {

    // MARK: - Dependencies

    private let router: Router
    private let catalogServer: CatalogServer
    private let container: Container
    private let userDefaults: UserDefaults

    var shouldRememberAction = false

    // MARK: - Init

    init(
        router: Router,
        catalogServer: CatalogServer,
        container: Container,
        userDefaults: UserDefaults,
        initialState: RemoteState
    ) {
        self.router = router
        self.catalogServer = catalogServer
        self.container = container
        self.userDefaults = userDefaults
    }

    // MARK: - Internal methods

    func handleInitialState(_ state: RemoteState) {
        if let option = state.defaultOption {
            switch option {
            case .client:
                guard let creds = state.lastConnectedCredentials else { return }

                showCatalog(
                    host: creds.host,
                    port: creds.port,
                    isAnimated: false
                )
            case .server:
                showServerView(isAnimated: false)
            }
        }
    }

    // MARK: - RemoteEnv

    func showServerView(isAnimated: Bool) {
        defer { rememberOptionIfNeeded(option: .server) }

        let view = ServerFeatueFactory.make(router: router, catalogServer: catalogServer) { [weak self] in
            self?.router.pop(isAnimated: true)
        }

        if shouldRememberAction {
            userDefaults.set(RemoteState.Option.server.rawValue, forKey: UserDefaultsKeys.remoteOption)
        }

        router.pushToView(view: view, isAnimated: isAnimated)
    }

    func showCatalog(
        host: String,
        port: Int,
        isAnimated: Bool
    ) {
        defer { rememberOptionIfNeeded(option: .client) }

        let input = CatalogFeatureInterface.Input(router: router, credentials: (host, port))

        guard let interface = container.resolve(
            CatalogFeatureInterface.self,
            name: "remote",
            argument: input
        ) else {
            return
        }

        userDefaults.set(host, forKey: UserDefaultsKeys.lastConnectedHost)
        userDefaults.set(port, forKey: UserDefaultsKeys.lastConnectedPort)

        router.pushToView(viewController: interface.viewController, isAnimated: isAnimated)
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

    // MARK: - Private methods

    private func rememberOptionIfNeeded(option: RemoteState.Option) {
        if shouldRememberAction {
            userDefaults.set(
                option.rawValue,
                forKey: UserDefaultsKeys.remoteOption
            )
        }
    }
}

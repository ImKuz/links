import ComposableArchitecture
import ToolKit
import Foundation
import Models

// MARK: - State

struct RemoteState: Equatable {
    var isRememberSwitchOn = false
    var defaultOption: Option?
    var lastConnectedCredentials: ServerCredentials?

    enum Option: Int, Equatable {
        case server, client
    }
}

// MARK: - Action

enum RemoteAction: Equatable {
    case connectTap
    case hostTap
    case toggleSwitch(isOn: Bool)
}

// MARK: - Enviroment

protocol RemoteEnv: AnyObject {
    var shouldRememberAction: Bool { get set }

    func showServerView(isAnimated: Bool)

    func showCatalog(
        host: String,
        port: Int,
        isAnimated: Bool
    )

    func showConnectForm() -> Effect<(String, Int), Never>
}

// MARK: - Reducer

let remoteReducer = Reducer<RemoteState, RemoteAction, RemoteEnv> { state, action, env in
    switch action {
    case .connectTap:
        return env
            .showConnectForm()
            .flatMap { host, port -> Effect<Void, Never> in
                env.showCatalog(
                    host: host,
                    port: port,
                    isAnimated: true
                )
                return .none
            }
            .fireAndForget()
    case .hostTap:
        env.showServerView(isAnimated: true)
        return .none
    case let .toggleSwitch(isOn):
        state.isRememberSwitchOn = isOn
        env.shouldRememberAction = isOn
        return .none
    }
}

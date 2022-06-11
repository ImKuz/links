import ComposableArchitecture
import ToolKit
import Foundation
import Models

// MARK: - State

struct RemoteState: Equatable {
    var isRememberSwitchOn = false
}

// MARK: - Action

enum RemoteAction: Equatable {
    case connectTap
    case hostTap
    case toggleSwitch(isOn: Bool)
}

// MARK: - Enviroment

protocol RemoteEnv {
    func showServerView(isAnimated: Bool)
    func showCatalog(host: String, port: Int) -> Effect<Void, Never>
    func showConnectForm() -> Effect<(String, Int), Never>
}

// MARK: - Reducer

let remoteReducer = Reducer<RemoteState, RemoteAction, RemoteEnv> { state, action, env in
    switch action {
    case .connectTap:
        return env
            .showConnectForm()
            .flatMap { host, port in
                env.showCatalog(host: host, port: port)
            }
            .fireAndForget()
    case .hostTap:
        env.showServerView(isAnimated: true)
        return .none
    case let .toggleSwitch(isOn):
        state.isRememberSwitchOn = isOn
        return .none
    }
}

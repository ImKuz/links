import ComposableArchitecture
import ToolKit
import Foundation
import Models

// MARK: - State

struct RemoteState: Equatable {
    var host = ""
    var port = "8090"
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

}

// MARK: - Reducer

let remoteReducer = Reducer<RemoteState, RemoteAction, RemoteEnv> { state, action, env in
    switch action {
    case .connectTap:
        return .none
    case .hostTap:
        return .none
    case let .toggleSwitch(isOn):
        state.isRememberSwitchOn = isOn
        return .none
    }
}

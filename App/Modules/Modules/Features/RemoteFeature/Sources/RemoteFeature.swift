import ComposableArchitecture
import ToolKit
import Foundation
import Models

// MARK: - State

struct RemoteState: Equatable {
    @BindableState var host = ""
    @BindableState var port = "8090"
    @BindableState var isAlertShown = false
    @BindableState var isRememberSwitchOn = false
}

// MARK: - Action

enum RemoteAction: BindableAction, Equatable {
    case binding(BindingAction<RemoteState>)
    case connectTap
    case hostTap
}

// MARK: - Enviroment

protocol RemoteEnv {

}

// MARK: - Reducer

let remoteReducer = Reducer<RemoteState, RemoteAction, RemoteEnv> { state, action, env in
    switch action {
    case .binding:
        return .none
    case .connectTap:
        state.isAlertShown.toggle()
        return .none
    case .hostTap:
        return .none
    }
}

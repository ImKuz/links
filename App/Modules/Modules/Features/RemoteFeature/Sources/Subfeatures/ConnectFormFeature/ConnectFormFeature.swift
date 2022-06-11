import ComposableArchitecture
import ToolKit
import Foundation
import Models

// MARK: - State

struct ConnectFormState: Equatable {
    @BindableState var host: String = ""
    @BindableState var port: String = ""
    @BindableState var isFormValid = false
}

// MARK: - Action

enum ConnectFormAction: BindableAction {
    case binding(BindingAction<ConnectFormState>)
    case validationResult(Bool)
    case doneTap
    case cancelTap
}

// MARK: - Enviroment

protocol ConnectFormEnv {
    var onDone: ((String, Int) -> ())? { get set }
    var onCancel: (() -> ())? { get set }

    func validateState(_ state: ConnectFormState) -> Effect<Bool, Never>
}

// MARK: - Reducer

let connectFormReducer = Reducer<ConnectFormState, ConnectFormAction, ConnectFormEnv> { state, action, env in
    switch action {
    case .binding:
        return env
            .validateState(state)
            .eraseToEffect { .validationResult($0) }
    case let .validationResult(isValid):
        state.isFormValid = isValid
        return .none
    case .doneTap:
        guard let port = Int(state.port) else {
            assertionFailure("Unexpected state")
            return .none
        }

        env.onDone?(state.host, port)
        return .none
    case .cancelTap:
        env.onCancel?()
        return .none
    }
}.binding()

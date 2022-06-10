import ComposableArchitecture
import ToolKit
import Foundation
import Models

// MARK: - State

struct ServerState: Equatable {
    var defaultPort = "8099"
    var port = ""
    var host = ""
    var isStarted = false

    var action: Action {
        isStarted ? .stop : .start
    }

    enum Action {
        case start
        case stop
    }
}

// MARK: - Action

enum ServerAction {
    case actionTap
    case closeTap
    case portEdited(String)
    case handleStart(Result<(String, Int)?, AppError>)
    case handleStop(Result<Void, AppError>)
}

// MARK: - Enviroment

protocol ServerEnv {
    func start(port: Int) -> Effect<(String, Int)?, AppError>
    func stop() -> Effect<Void, AppError>
    func showInfoAlert(title: String, message: String?) -> Effect<Void, Never>
    func close()
}

// MARK: - Reducer

let serverReducer = Reducer<ServerState, ServerAction, ServerEnv> { state, action, env in
    switch action {
    case .actionTap:
        if state.isStarted {
            return env
                .stop()
                .receive(on: DispatchQueue.main)
                .catchToEffect(ServerAction.handleStop)
        } else {
            let portString = state.port.isEmpty ? state.defaultPort : state.port
            guard let port = Int(portString) else { return .none }

            return env
                .start(port: port)
                .receive(on: DispatchQueue.main)
                .catchToEffect(ServerAction.handleStart)
        }
    case .closeTap:
        env.close()
        return env.stop().fireAndForget()
    case .portEdited(let text):
        state.port = text
        return .none
    case .handleStart(let result):
        switch result {
        case .failure(let error):
            if case let .businessLogic(text) = error {
                return env.showInfoAlert(title: text, message: nil).fireAndForget()
            } else {
                return .none
            }
        case .success(let host):
            if let host = host {
                state.host = host.0
                state.port = String(host.1)
            }

            state.isStarted = true
            return .none
        }
    case .handleStop(let result):
        switch result {
        case .success:
            state.isStarted = false
            state.host = ""
            return .none
        case .failure(let error):
            if case let .businessLogic(text) = error {
                return env.showInfoAlert(title: text, message: nil).fireAndForget()
            } else {
                return .none
            }
        }
    }
}

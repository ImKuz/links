import Combine
import ComposableArchitecture

final class ConnectFormEnvImpl: ConnectFormEnv {

    var onDone: ((String, Int) -> ())?
    var onCancel: (() -> ())?

    func validateState(_ state: ConnectFormState) -> Effect<Bool, Never> {
        let isValid = [
            !state.host.isEmpty,
            !state.port.isEmpty,
            Int(state.port) != nil,
        ]
        .allSatisfy { $0 }

        return Effect(value: isValid)
    }
}

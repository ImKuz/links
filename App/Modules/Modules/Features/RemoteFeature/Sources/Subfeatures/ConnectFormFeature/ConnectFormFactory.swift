import ComposableArchitecture
import Models

enum ConnectFormFactory {
    static func make(
        defaultHost: String?,
        defaultPort: Int?,
        onDone: ((String, Int) -> ())?,
        onCancel: (() -> ())?
    ) -> ConnectFormView {
        let env = ConnectFormEnvImpl()

        env.onCancel = onCancel
        env.onDone = onDone

        let host = defaultHost ?? ""

        let port: String

        if let intPort = defaultPort {
            port = String(intPort)
        } else {
            port = ""
        }

        let store = Store<ConnectFormState, ConnectFormAction>(
            initialState: .init(
                host: host,
                port: port
            ),
            reducer: connectFormReducer,
            environment: env
        )

        return ConnectFormView(store: store)
    }
}

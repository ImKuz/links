import ComposableArchitecture

enum ConnectFormFactory {
    static func make(
        onDone: ((String, Int) -> ())?,
        onCancel: (() -> ())?
    ) -> ConnectFormView {
        let env = ConnectFormEnvImpl()

        env.onCancel = onCancel
        env.onDone = onDone

        let store = Store<ConnectFormState, ConnectFormAction>(
            initialState: .init(),
            reducer: connectFormReducer,
            environment: env
        )

        return ConnectFormView(store: store)
    }
}

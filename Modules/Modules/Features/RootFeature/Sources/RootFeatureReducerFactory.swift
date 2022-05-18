import ComposableArchitecture
import SharedEnv

struct RootReducerFactory {

    static func make() -> RootReducerType {
        Reducer { state, action, env in .none }
    }
}

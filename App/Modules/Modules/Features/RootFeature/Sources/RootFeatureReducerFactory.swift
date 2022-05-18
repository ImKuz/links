import ComposableArchitecture
import SharedEnv

struct RootReducerFactory {

    static func make() -> RootReducerType {
        Reducer { _, _, _ in return .none }
    }
}

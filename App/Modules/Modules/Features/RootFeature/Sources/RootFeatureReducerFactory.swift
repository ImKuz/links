import ComposableArchitecture

struct RootReducerFactory {

    static func make() -> RootReducerType {
        Reducer.empty
    }
}

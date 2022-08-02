import ComposableArchitecture
import Combine

public extension Publisher where Output == Void, Failure == Never {

    func eraseToEmptyEffect<NewOutputType>() -> Effect<NewOutputType, Never> {
        Effect<NewOutputType, Never>.none
    }
}

public extension Publisher where Output == Void {

    func catchToEmptyEffect<NewOutputType>(
        _ errorHandler: @escaping (Failure) -> NewOutputType
    ) -> Effect<NewOutputType, Never> {
        flatMap { Effect<NewOutputType, Never>.none }
        .catchToEffect {
            switch $0 {
            case let .failure(error):
                return errorHandler(error)
            case let .success(value):
                return value
            }
        }
    }
}

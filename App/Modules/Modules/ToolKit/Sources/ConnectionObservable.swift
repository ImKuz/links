import Combine

public enum ConnectionState {
    case ok
    case failure
    case connecting
}

public protocol ConnectionObservable {
    var connectivityPublisher: AnyPublisher<ConnectionState, Never> { get }
}

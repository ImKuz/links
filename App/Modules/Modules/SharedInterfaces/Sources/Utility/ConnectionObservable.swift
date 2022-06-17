import Combine
import Models

public protocol ConnectionObservable {
    var connectivityPublisher: AnyPublisher<ConnectionState, Never> { get }
}

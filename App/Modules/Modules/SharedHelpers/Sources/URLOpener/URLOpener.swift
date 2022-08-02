import Combine
import ToolKit
import UIKit

public protocol URLOpener {

    func open(_ url: URL) -> AnyPublisher<Void, AppError>
    func open(_ urlString: String) -> AnyPublisher<Void, AppError>
}

final class URLOpenerImpl: URLOpener {

    func open(_ url: URL) -> AnyPublisher<Void, AppError> {
        Future { promise in
            guard UIApplication.shared.canOpenURL(url) else {
                return promise(.failure(.businessLogic("Unable to open URL")))
            }

            UIApplication.shared.open(url) { _ in
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    func open(_ urlString: String) -> AnyPublisher<Void, AppError> {
        guard let url = URL(string: urlString) else {
            return Fail(error: .businessLogic("Invalid URL")).eraseToAnyPublisher()
        }

        return open(url)
    }
}

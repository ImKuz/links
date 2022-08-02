import Combine
import ToolKit
import UIKit

public protocol URLOpener {

    func openUrl(_ url: URL) -> AnyPublisher<Void, AppError>
}

final class URLOpenerImpl: URLOpener {

    func openUrl(_ url: URL) -> AnyPublisher<Void, AppError> {
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
}

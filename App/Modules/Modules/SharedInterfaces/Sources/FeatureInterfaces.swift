import SwiftUI
import ToolKit
import Combine
import Models
import UIKit

public protocol FeatureInterface {
    var view: AnyView { get }
}

public struct CatalogFeatureInterface {

    public typealias Credentials = (host: String, port: Int)

    public struct Input {
        public let router: Router
        public let credentials: Credentials?

        public init(router: Router, credentials: Credentials?) {
            self.router = router
            self.credentials = credentials
        }
    }

    public var viewController: UIViewController

    public init(viewController: UIViewController) {
        self.viewController = viewController
    }
}

public struct RootFeatureInterface: FeatureInterface {

    public var view: AnyView

    public init(view: AnyView) {
        self.view = view
    }
}

public struct AddItemFeatureInterface: FeatureInterface {

    public typealias Input = CatalogSource

    public var view: AnyView
    public var onFinishPublisher: AnyPublisher<Void, Never>

    public init(
        view: AnyView,
        onFinishPublisher: AnyPublisher<Void, Never>
    ) {
        self.view = view
        self.onFinishPublisher = onFinishPublisher
    }
}

public struct RemoteFeatureInterface: FeatureInterface {

    public var view: AnyView

    public init(view: AnyView) {
        self.view = view
    }
}

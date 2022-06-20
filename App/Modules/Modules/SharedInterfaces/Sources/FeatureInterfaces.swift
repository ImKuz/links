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

        public enum Mode {
            case local(LocalModeConfig)
            case remote(RemoteModeConfig)
        }

        public let router: Router
        public let title: String
        public let mode: Mode

        public init(
            router: Router,
            title: String,
            mode: Mode
        ) {
            self.router = router
            self.title = title
            self.mode = mode
        }
    }

    public struct RemoteModeConfig {
        public let host: String
        public let port: Int

        public init(host: String, port: Int) {
            self.host = host
            self.port = port
        }
    }

    public struct LocalModeConfig {
        public let topLevelPredicate: NSPredicate?

        public init(topLevelPredicate: NSPredicate?) {
            self.topLevelPredicate = topLevelPredicate
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

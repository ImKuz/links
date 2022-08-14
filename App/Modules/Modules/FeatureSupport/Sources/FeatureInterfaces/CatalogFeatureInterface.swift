import CatalogSource
import SwiftUI
import UIKit
import ToolKit
import Models

public struct CatalogFeatureInterface: FeatureInterface {

    public typealias Credentials = (host: String, port: Int)

    public var viewController: UIViewController

    public var view: AnyView {
        AnyView(UIViewControllerHolder(controller: viewController))
    }

    public init(viewController: UIViewController) {
        self.viewController = viewController
    }
}

public extension CatalogFeatureInterface {

    struct Input {

        public let router: Router
        public let title: String
        public let config: CatalogSourceConfig

        public init(
            router: Router,
            title: String,
            config: CatalogSourceConfig
        ) {
            self.router = router
            self.title = title
            self.config = config
        }
    }
}

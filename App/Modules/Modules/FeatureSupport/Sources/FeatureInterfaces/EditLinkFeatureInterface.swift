import Combine
import SwiftUI
import CatalogSource
import Models
import ToolKit

public struct EditLinkFeatureInterface: FeatureInterface {

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

public extension EditLinkFeatureInterface {

    struct Input {

        public let catalogSource: CatalogSource
        public let item: LinkItem
        public let router: Router

        public init(
            catalogSource: CatalogSource,
            item: LinkItem,
            router: Router
        ) {
            self.catalogSource = catalogSource
            self.item = item
            self.router = router
        }
    }
}

import SwiftUI
import ToolKit
import Combine
import Models

public protocol FeatureInterface {
    var view: AnyView { get }
}

public struct CatalogFeatureInterface: FeatureInterface {

    public var view: AnyView

    public init(view: AnyView) {
        self.view = view
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

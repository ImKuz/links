import SwiftUI
import Combine

public struct TextEditorFeatureInterface: FeatureInterface {

    public typealias Input = String

    public var view: AnyView
    public var onFinishPublisher: AnyPublisher<String, Never>

    public init(
        view: AnyView,
        onFinishPublisher: AnyPublisher<String, Never>
    ) {
        self.view = view
        self.onFinishPublisher = onFinishPublisher
    }
}

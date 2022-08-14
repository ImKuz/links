import SwiftUI

public struct RemoteFeatureInterface: FeatureInterface {

    public typealias Input = Void
    public var view: AnyView

    public init(view: AnyView) {
        self.view = view
    }
}

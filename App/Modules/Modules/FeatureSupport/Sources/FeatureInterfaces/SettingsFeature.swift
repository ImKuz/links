import SwiftUI

public struct SettingsFeatureInterface: FeatureInterface {

    public typealias Input = Void
    public var view: AnyView

    public init(view: AnyView) {
        self.view = view
    }
}

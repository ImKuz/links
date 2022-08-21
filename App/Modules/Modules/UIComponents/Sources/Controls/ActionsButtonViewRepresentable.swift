import SwiftUI

public struct ActionsButtonViewRepresentable: UIViewRepresentable {

    public var onTap: ((ActionsButton) -> ())?

    public init(onTap: ((ActionsButton) -> ())?) {
        self.onTap = onTap
    }

    public func makeUIView(context: Context) -> ActionsButton {
        ActionsButton(onTap: onTap)
    }

    public func updateUIView(_ uiView: ActionsButton, context: Context) {

    }
}

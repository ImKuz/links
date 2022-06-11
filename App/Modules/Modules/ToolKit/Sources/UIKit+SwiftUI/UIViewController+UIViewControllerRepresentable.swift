import SwiftUI
import UIKit

public struct UIViewControllerHolder: UIViewControllerRepresentable  {

    private let controller: UIViewController

    public init(controller: UIViewController) {
        self.controller = controller
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        controller
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // no-op
    }
}

import SwiftUI
import UIKit

public struct UINavigationControllerHolder: UIViewControllerRepresentable  {

    private let navigationController: UINavigationController

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func makeUIViewController(context: Context) -> UINavigationController {
        navigationController
    }

    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // no-op
    }
}

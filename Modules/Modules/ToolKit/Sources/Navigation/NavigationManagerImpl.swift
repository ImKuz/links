#if !os(macOS)
import Foundation
import SwiftUI
import UIKit

public struct NavigationManagerImpl: NavigationManager {

    public init() {}

    public func changeRootView<T: View>(rootView: T) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let window = windowScene.keyWindow

        window?.rootViewController = UIHostingController(rootView: rootView)
    }

    public func presentView<T: View>(
        view: T,
        transitionStyle: UIModalTransitionStyle,
        presentStyle: UIModalPresentationStyle,
        isAnimated: Bool
    ) {
        let navigationController = Self.getCurrentNavigationController()

        let controller = UIHostingController(rootView: view)
        controller.modalTransitionStyle = transitionStyle
        controller.modalPresentationStyle = presentStyle

        navigationController?.present(
            controller,
            animated: isAnimated,
            completion: nil
        )
    }

    public func pushToView<T: View>(view: T, isAnimated: Bool) {
        Self.getCurrentNavigationController()?
            .pushViewController(
                UIHostingController(rootView: view),
                animated: isAnimated
            )
    }

    public func dismiss(isAnimated: Bool, completion: (() -> Void)?) {
        Self.getCurrentNavigationController()?
            .dismiss(
                animated: isAnimated,
                completion: completion
            )
    }

    public func pop(isAnimated: Bool) {
        Self.getCurrentNavigationController()?
            .popViewController(animated: isAnimated)
    }

    public func popToView<T: View>(
        _ viewType: T.Type,
        isAnimated: Bool,
        inPosition: PopPositionType
    ) {
        let navigationController = Self.getCurrentNavigationController()

        switch inPosition {
        case .last:
            if let vc = navigationController?.viewControllers.last(where: { $0 is UIHostingController<T> }) {
                navigationController?.popToViewController(vc, animated: isAnimated)
            }
        case .first:
            if let vc = navigationController?.viewControllers.first(where: { $0 is UIHostingController<T> }) {
                navigationController?.popToViewController(vc, animated: isAnimated)
            }
        }
    }

    public func popToRootView(isAnimated: Bool) {
        Self.getCurrentNavigationController()?
            .popToRootViewController(animated: isAnimated)
    }

    // MARK: - Private methods

    private static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
          return nil
        }

        if let navigationController = viewController as? UINavigationController {
          return navigationController
        }

        for childViewController in viewController.children {
          return findNavigationController(viewController: childViewController)
        }

        return nil
    }

    private static func getCurrentNavigationController() -> UINavigationController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        let viewController = windowScene.keyWindow?.rootViewController

        return findNavigationController(viewController: viewController)
    }
}
#endif

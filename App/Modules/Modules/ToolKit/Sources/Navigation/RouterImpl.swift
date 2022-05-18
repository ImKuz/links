import Foundation
import SwiftUI
import UIKit

public final class RouterImpl: Router {

    private let navigationController: UINavigationController

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func presentView<T: View>(
        view: T,
        transitionStyle: UIModalTransitionStyle,
        presentStyle: UIModalPresentationStyle,
        isAnimated: Bool
    ) {
        let controller = UIHostingController(rootView: view)

        controller.modalTransitionStyle = transitionStyle
        controller.modalPresentationStyle = presentStyle

        navigationController.present(
            controller,
            animated: isAnimated,
            completion: nil
        )
    }

    public func pushToView<T: View>(view: T, isAnimated: Bool) {
        navigationController
            .pushViewController(
                UIHostingController(rootView: view),
                animated: isAnimated
            )
    }

    public func dismiss(isAnimated: Bool, completion: (() -> ())?) {
        navigationController
            .dismiss(
                animated: isAnimated,
                completion: completion
            )
    }

    public func pop(isAnimated: Bool) {
        navigationController
            .popViewController(animated: isAnimated)
    }

    public func popToView<T: View>(
        _ viewType: T.Type,
        isAnimated: Bool,
        inPosition: PopPositionType
    ) {
        switch inPosition {
        case .last:
            if let vc = navigationController.viewControllers.last(where: { $0 is UIHostingController<T> }) {
                navigationController.popToViewController(vc, animated: isAnimated)
            }
        case .first:
            if let vc = navigationController.viewControllers.first(where: { $0 is UIHostingController<T> }) {
                navigationController.popToViewController(vc, animated: isAnimated)
            }
        }
    }

    public func popToRootView(isAnimated: Bool) {
        navigationController
            .popToRootViewController(animated: isAnimated)
    }
}

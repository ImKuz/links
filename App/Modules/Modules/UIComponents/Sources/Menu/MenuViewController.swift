import UIKit

public final class MenuViewController: UIViewController {

    private enum Spec {
        static let dimmDuration: TimeInterval = 0.1
    }

    private var focusedView: UIView?
    private var snapshotView: UIView?
    private var window: MenuWindow?
    private let tableViewController = MenuTableViewController()

    public var onActionTap: ((MenuAction) -> ())? {
        get { tableViewController.onActionTap }
        set { tableViewController.onActionTap = newValue }
    }

    public var onDismiss: (() -> ())?

    // MARK: - Init

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()

        tableViewController.onDismiss = { [weak self] in

            self?.dismiss()
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: Spec.dimmDuration) { [self] in
            view.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        }
    }

    // MARK: - Public methods

    public func updateMenuActions(_ actions: [MenuAction]) {
        tableViewController.configure(with: actions)
    }

    public func present(onto focusedView: UIView?, initialActions: [MenuAction] = []) {
        guard
            let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let focusedView = focusedView
        else {
            return
        }

        self.focusedView = focusedView

        window = .init(windowScene: currentWindowScene)
        window?.rootViewController = self
        window?.makeKeyAndVisible()

        showMenu(initialActions: initialActions)
    }

    public func dismiss() {
        snapshotView?.removeFromSuperview()
        snapshotView = nil
        focusedView = nil

        window?.isHidden = true
        window?.windowScene = nil
        window?.rootViewController = nil
        window = nil

        tableViewController.dismiss(animated: true)
    }

    // MARK: - Private methods

    private func highlightFocusedView() {
        guard
            let focusedView = focusedView,
            let snapshotView = focusedView.snapshotView(afterScreenUpdates: false),
            let focusedViewSuperview = focusedView.superview
        else {
            return
        }

        view.addSubview(snapshotView)
        let convertedFrame = view.convert(focusedView.frame, from: focusedViewSuperview)
        snapshotView.frame = convertedFrame
        self.snapshotView = snapshotView
    }

    private func showMenu(initialActions: [MenuAction]) {
        guard presentedViewController != tableViewController else {
            return updateMenuActions(initialActions)
        }

        highlightFocusedView()

        tableViewController.modalPresentationStyle = .popover
        tableViewController.popoverPresentationController?.delegate = self
        tableViewController.popoverPresentationController?.sourceView = snapshotView
        tableViewController.popoverPresentationController?.sourceRect = snapshotView?.bounds ?? .zero
        tableViewController.popoverPresentationController?.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        updateMenuActions(initialActions)
        present(tableViewController, animated: true)
    }
}

extension MenuViewController: UIPopoverPresentationControllerDelegate {

    public func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }
}

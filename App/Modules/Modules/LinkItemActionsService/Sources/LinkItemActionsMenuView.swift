import SwiftUI
import UIKit

public protocol LinkItemActionsMenuViewDelegate: AnyObject {

    func linkItemActionsMenuViewRequestsAcitons(
        view: LinkItemActionsMenuView
    ) async -> [LinkItemAction.WithData]
}

public final class LinkItemActionsMenuView: UIButton {

    private enum Spec {
        static let iconSize = CGSize(width: 16, height: 8)
        static let iconOverlayPadding: CGFloat = 10
    }

    // MARK: - Public properties

    public weak var delegate: LinkItemActionsMenuViewDelegate?
    public var onAction: ((LinkItemAction.WithData) -> ())?

    // MARK: - Subviews

    private let iconView: UIImageView = {
        let view = UIImageView()

        view.contentMode = .center
        view.image = UIImage(systemName: "ellipsis")?.withTintColor(.systemBlue)

        return view
    }()

    private let overlayView: UIView = {
        let view = UIView()

        view.backgroundColor = .systemBlue.withAlphaComponent(0.25)
        view.layer.cornerRadius = 6

        return view
    }()

    // MARK: - Init

    public init(
        delegate: LinkItemActionsMenuViewDelegate?,
    	onAction: ((LinkItemAction.WithData) -> ())?
    ) {
        self.delegate = delegate
        self.onAction = onAction
        super.init(frame: .zero)

        addSubview(overlayView)
        addSubview(iconView)
        showsMenuAsPrimaryAction = true
        menu = makeMenu()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIView

    public override func layoutSubviews() {
        super.layoutSubviews()
        iconView.frame.size = Spec.iconSize
        iconView.center = center

        overlayView.frame.size = CGSize(
            width: Spec.iconSize.width + Spec.iconOverlayPadding,
            height: Spec.iconSize.height + Spec.iconOverlayPadding
        )
        overlayView.center = center
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(
            width: Spec.iconSize.width + Spec.iconOverlayPadding,
            height: Spec.iconSize.height + Spec.iconOverlayPadding
        )
    }

    // MARK: - Private methods

    private func loadMenuElements(completion: @escaping ([UIMenuElement]) -> ()) {
        guard let delegate = delegate else { return }

        Task {
            let actions = await delegate.linkItemActionsMenuViewRequestsAcitons(view: self)

            let menuItems: [UIMenuElement] = actions.map { action in
                let label = action.data.label

                return UIAction(
                    title: label?.title ?? "",
                    image: UIImage(systemName: label?.iconName ?? ""),
                    attributes: action.data.isDestructive ? .destructive : [],
                    handler: { [weak self, action] _ in
                        self?.onAction?(action)
                    }
                )
            }

            completion(menuItems)
        }
    }

    private func makeMenu() -> UIMenu? {
        UIMenu(
            options: .displayInline,
            children: [
                UIDeferredMenuElement(loadMenuElements)
            ]
        )
    }
}

public struct LinkItemActionsMenuViewRepresentable: UIViewRepresentable {

    public weak var delegate: LinkItemActionsMenuViewDelegate?
    public var onAction: ((LinkItemAction.WithData) -> ())?

    public init(
        delegate: LinkItemActionsMenuViewDelegate? = nil,
        onAction: ((LinkItemAction.WithData) -> ())? = nil
    ) {
        self.delegate = delegate
        self.onAction = onAction
    }


    public func makeUIView(context: Context) -> LinkItemActionsMenuView {
        LinkItemActionsMenuView(delegate: delegate, onAction: onAction)
    }

    public func updateUIView(_ uiView: LinkItemActionsMenuView, context: Context) {

    }
}

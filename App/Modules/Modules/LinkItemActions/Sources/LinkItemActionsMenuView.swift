import SwiftUI
import UIKit

public protocol LinkItemActionsMenuViewDelegate: AnyObject {

    func linkItemActionsMenuViewRequestsAcitons(
        view: LinkItemActionsMenuView
    )
}

public final class LinkItemActionsMenuView: UIButton {

    private enum Spec {
        static let iconSize = CGSize(width: 16, height: 8)
        static let iconOverlayPadding: CGFloat = 10
    }

    // MARK: - Public properties

    public var actionsProvider: ((String) async -> [LinkItemAction.WithData])?
    public var onAction: ((LinkItemAction.WithData) -> ())?
    public var itemId: String?

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
        itemId: String?,
        actionsProvider: ((String) async -> [LinkItemAction.WithData])?,
    	onAction: ((LinkItemAction.WithData) -> ())?
    ) {
        self.itemId = itemId
        self.actionsProvider = actionsProvider
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
        iconView.frame = CGRect(
            x: bounds.midX - Spec.iconSize.width / 2,
            y: bounds.midY - Spec.iconSize.height / 2,
            width: Spec.iconSize.width,
            height: Spec.iconSize.height
        )

        let overlaySize = CGSize(
            width: Spec.iconSize.width + Spec.iconOverlayPadding,
            height: Spec.iconSize.height + Spec.iconOverlayPadding
        )

        overlayView.frame = CGRect(
            x: bounds.midX - overlaySize.width / 2,
            y: bounds.midY - overlaySize.height / 2,
            width: overlaySize.width,
            height: overlaySize.height
        )
    }

    // MARK: - Private methods

    private func loadMenuElements(completion: @escaping ([UIMenuElement]) -> ()) {
        Task { () -> () in
            guard let itemId = itemId else { return completion([]) }

            let actions = await actionsProvider?(itemId) ?? []

            print(actions)

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
            options: .singleSelection,
            children: [
                UIDeferredMenuElement { [weak self] in
                    self?.loadMenuElements(completion: $0)
                }
            ]
        )
    }
}

public struct LinkItemActionsMenuViewRepresentable: UIViewRepresentable {

    public var actionsProvider: ((String) async -> [LinkItemAction.WithData])?
    public var onAction: ((LinkItemAction.WithData) -> ())?
    public var itemId: String?

    public init(
        itemId: String?,
        actionsProvider: ((String) async -> [LinkItemAction.WithData])? = nil,
        onAction: ((LinkItemAction.WithData) -> ())? = nil
    ) {
        self.actionsProvider = actionsProvider
        self.onAction = onAction
        self.itemId = itemId
    }

    public func makeUIView(context: Context) -> LinkItemActionsMenuView {
        LinkItemActionsMenuView(
            itemId: itemId,
            actionsProvider: actionsProvider,
            onAction: onAction
        )
    }

    public func updateUIView(_ uiView: LinkItemActionsMenuView, context: Context) {

    }
}

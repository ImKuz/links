import UIKit

public final class ActionsButton: UIButton {

    private enum Spec {
        static let iconSize = CGSize(width: 16, height: 8)
        static let iconOverlayPadding: CGFloat = 10
    }

    // MARK: - Public properties

    public var onTap: ((ActionsButton) -> ())?

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

    public init(onTap: ((ActionsButton) -> ())? = nil) {
        self.onTap = onTap
        super.init(frame: .zero)

        addSubview(overlayView)
        addSubview(iconView)

        overlayView.isUserInteractionEnabled = false
        iconView.isUserInteractionEnabled = false

        addTarget(self, action: #selector(didTap), for: .touchUpInside)
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

    @objc
    private func didTap() {
        onTap?(self)
    }
}

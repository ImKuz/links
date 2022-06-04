import ComposableArchitecture
import UIKit

final class CatalogRowCell: UICollectionViewCell {

    static var reuseId = "CatalogRowCell"

    // MARK: - Subviews

    private let titleLabel: UILabel = {
        let label = UILabel()

        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 1

        return label
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()

        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label.textColor = .placeholderText
        label.numberOfLines = 2

        return label
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private lazy var showMoreButton: UIButton = {
        let button = UIButton()

        button.setImage(
            UIImage(systemName: "ellipsis"),
            for: .normal
        )

        button.menu = makeMenu()
        button.showsMenuAsPrimaryAction = true

        return button
    }()

    // MARK: - Private properties

    private var viewStore: ViewStore<CatalogRowState, CatalogRowAction>?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemBackground
        layer.cornerRadius = 8

        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(showMoreButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        let contentFrame = contentView.bounds
        let iconSize = CGSize(width: 22, height: 22)
        let buttonSize = CGSize(width: 44, height: 44)

        let labelWidth = contentFrame.width
            - iconSize.width
            - buttonSize.width
            - 8 * 2

        iconImageView.frame = CGRect(
            x: contentFrame.minX + 8,
            y: contentFrame.midY - iconSize.height / 2,
            width: iconSize.width,
            height: iconSize.height
        )

        titleLabel.frame = CGRect(
            x: iconImageView.frame.maxX + 8,
            y: contentFrame.minX + 8,
            width: labelWidth,
            height: titleLabel.sizeThatFits(contentFrame.size).height
        )

        contentLabel.frame = CGRect(
            x: titleLabel.frame.minX,
            y: titleLabel.frame.maxY,
            width: labelWidth,
            height: contentLabel.sizeThatFits(
                CGSize(width: labelWidth, height: .zero)
            ).height
        )

        showMoreButton.frame = CGRect(
            x: contentFrame.maxX - buttonSize.width,
            y: contentFrame.midY - buttonSize.height / 2,
            width: buttonSize.width,
            height: buttonSize.height
        )
    }

    // MARK: - State

    func set(store: Store<CatalogRowState, CatalogRowAction>) {
        self.viewStore = ViewStore(store)
        updateState()
    }

    private func updateState() {
        guard let viewStore = viewStore else { return }

        titleLabel.text = viewStore.title
        contentLabel.text = viewStore.content
        iconImageView.image = UIImage(systemName: viewStore.icon.rawValue)
    }

    // MARK: - Context menu

    private func makeMenu() -> UIMenu {
        UIMenu(
            options: .displayInline,
            children: [
                UIAction(
                    title: "Delete",
                    image: UIImage(systemName: "trash"),
                    attributes: [.destructive],
                    handler: { [weak self] _ in
                        self?.viewStore?.send(.onDelete)
                    }
                )
            ]
        )
    }

}

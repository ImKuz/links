import UIKit
import ToolKit

final class MenuTableViewController: UITableViewController {

    private enum Spec {
        static let cellId = "cell"
        static let font = UIFont.systemFont(ofSize: 16)
    }

    private var actions = [MenuAction]()

    var onActionTap: ((MenuAction) -> ())?
    var onDismiss: (() -> ())?

    var longestActionName: String? {
        var longestSoFar: String?

        actions
            .map(\.name)
            .forEach {
                if (longestSoFar ?? "").count < $0.count {
                    longestSoFar = $0
                }
            }

        return longestSoFar
    }

    // MARK: - Public methods

    func configure(with actions: [MenuAction]) {
        self.actions = actions
        reloadMenu()
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Spec.cellId)
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        preferredContentSize = .init(width: 200, height: .zero)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            onDismiss?()
        }
    }

    // MARK: - UITableViewDelegate

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        onActionTap?(actions[indexPath.row])
    }

    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        44
    }

    // MARK: - UITableViewDataSource

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        actions.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Spec.cellId, for: indexPath)
        let item = actions[indexPath.row]
        let color: UIColor = item.isDestructive ? .red : .label
        var config = UIListContentConfiguration.cell()

        config.attributedText = NSAttributedString(
            string: item.name,
            attributes: [
                .font: Spec.font,
                .foregroundColor: color
            ]
        )

        config.image = UIImage(systemName: item.iconName ?? "")
        config.imageProperties.tintColor = color
        
        cell.selectionStyle = .none
        cell.contentConfiguration = config

        return cell
    }

    // MARK: - Private methods

    private func reloadMenu() {
        tableView.reloadData()

        guard let longestActionName = longestActionName else { return }

        let stringWidth = NSAttributedString(
            string: longestActionName,
            attributes: [ .font: Spec.font ]
        ).width(withConstrainedHeight: 44)

        let width = stringWidth + 100

        preferredContentSize = CGSize(width: width, height: tableView.contentSize.height)
    }
}

import IdentifiedCollections
import ComposableArchitecture
import UIKit
import Models
import Combine
import Foundation
import LinkItemActions
import UIComponents

final class CatalogViewController: UICollectionViewController {

    private let store: Store<CatalogState, CatalogAction>
    private let viewStore: ViewStore<CatalogState, CatalogAction>
    private let catalogUpdatePublisher: AnyPublisher<Void, Never>
    private let menuViewController = MenuViewController()

    private var cancellables = [AnyCancellable]()
    private var currentItems = IdentifiedArrayOf<LinkItem>()
    private var menuPresentedItem: LinkItem?

    var actionsProvider: ((LinkItem.ID) async -> [LinkItemAction.WithData])?

    // MARK: - Init

    init(
        store: Store<CatalogState, CatalogAction>,
        catalogUpdatePublisher: AnyPublisher<Void, Never>
    ) {
        self.store = store
        self.viewStore = ViewStore(store)
        self.catalogUpdatePublisher = catalogUpdatePublisher
        super.init(collectionViewLayout: .init())
        collectionView.setCollectionViewLayout(makeCollectionViewLayout(), animated: false)
        collectionView.dragInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.register(
            CatalogRowCell.self,
            forCellWithReuseIdentifier: CatalogRowCell.reuseId
        )

        viewStore.send(.viewDidLoad)
    }

    // MARK: - State

    private func setupBinding() {
        weak var weakSelf = self

        catalogUpdatePublisher
            .sink {
                weakSelf?.collectionView.reloadData()
            }
            .store(in: &cancellables)

        viewStore.publisher
            .items
            .sink { newItems in
                weakSelf?.apllyDiff(newItems: newItems)
            }
            .store(in: &cancellables)

        viewStore.publisher
            .title
            .sink { title in
                weakSelf?.title = title
            }
            .store(in: &cancellables)

        viewStore.publisher
            .titleMessage
            .map { $0 ?? weakSelf?.viewStore.title }
            .sink { title in
                weakSelf?.title = title
            }
            .store(in: &cancellables)

        viewStore.publisher
            .leftButton
            .sink { config in
                weakSelf?.setupLeftButton(config)
            }
            .store(in: &cancellables)

        viewStore.publisher
            .rightButton
            .sink { config in
                weakSelf?.setupRightButton(config)
            }
            .store(in: &cancellables)

        menuViewController.onActionTap = { action in
            guard
                let linkItemAction = LinkItemAction(rawValue: action.id),
                let itemId = weakSelf?.menuPresentedItem?.id
            else {
                return
            }

            let rowAction = CatalogRowAction.linkItemAction(linkItemAction)

            weakSelf?.menuViewController.dismiss()
            weakSelf?.viewStore.send(
                .rowAction(id: itemId, action: rowAction)
            )
        }

        menuViewController.onDismiss = {
            weakSelf?.menuPresentedItem = nil
        }
    }

    private func setupLeftButton(_ config: ButtonConfig?) {
        if let  config = config {
            navigationItem.leftBarButtonItem = makeBarButton(config: config)
        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }

    private func setupRightButton(_ config: ButtonConfig?) {
        if let  config = config {
            navigationItem.rightBarButtonItem = makeBarButton(config: config)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    private func makeBarButton(config: ButtonConfig) -> UIBarButtonItem {
        var image: UIImage?

        if let imageName = config.systemImageName {
            image = UIImage(systemName: imageName)
        }

        let button = UIBarButtonItem(
            title: config.title,
            image: image,
            primaryAction: .init { [weak self] _ in
                self?.viewStore.send(config.action)
            },
            menu: nil
        )

        button.tintColor = config.tintColor

        return button
    }

    private func apllyDiff(newItems: IdentifiedArrayOf<LinkItem>) {
        let diff = newItems.difference(from: currentItems)

        guard !diff.isEmpty else { return }

        var removeIndexPaths = [IndexPath]()
        var insertIndexPaths = [IndexPath]()

        for change in diff {
            switch change {
            case let .insert(offset, _, _):
                insertIndexPaths.append(IndexPath(row: offset, section: 0))
            case let .remove(offset, _, _):
                removeIndexPaths.append(IndexPath(row: offset, section: 0))
            }
        }

        currentItems = newItems

        if insertIndexPaths.count != removeIndexPaths.count {
            collectionView.reloadData()
        } else {
            collectionView.performBatchUpdates {
                collectionView.deleteItems(at: removeIndexPaths)
                collectionView.insertItems(at: insertIndexPaths)
            }
        }
    }

    // MARK: - UICollectionViewDataSource

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        currentItems.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CatalogRowCell.reuseId,
            for: indexPath
        ) as? CatalogRowCell

        guard let cell = cell else { fatalError("Unable to dequeue cell") }

        let item = currentItems[indexPath.row]

        let state = CatalogRowState(
            id: item.id,
            title: item.name,
            contentPreview: item.urlString
        )

        cell.onActionButtonTap = { [weak self, item] button in
            self?.menuPresentedItem = item
            self?.showMenu(onto: button, itemId: item.id)
        }

        cell.set(
            store: store.scope(
                state: { _ in state },
                action: { CatalogAction.rowAction(id: item.id, action: $0) }
            )
        )

        return cell
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(
        _ collectionView: UICollectionView,
        canMoveItemAt indexPath: IndexPath
    ) -> Bool {
        viewStore.canMoveItems
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        moveItemAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        let temp = currentItems.remove(at: sourceIndexPath.item)
        currentItems.insert(temp, at: destinationIndexPath.item)

        viewStore.send(
            .moveItem(
                from: sourceIndexPath.row,
                to: destinationIndexPath.row
            )
        )
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let item = viewStore.items[indexPath.row]
        viewStore.send(.rowAction(id: item.id, action: .tap))
    }

    // MARK: - Private methods

    private func showMenu(onto view: UIView, itemId: LinkItem.ID) {
        menuViewController.present(
            onto: view,
            initialActions: [
                .init(id: "loader", name: "Loading", iconName: "rays")
            ]
        )

        Task {
            guard let actions = await actionsProvider?(itemId) else { return }
            let menuActions = actions.map {
                MenuAction(
                    id: $0.action.rawValue,
                    name: $0.data.label?.title ?? "",
                    iconName: $0.data.label?.iconName ?? "",
                    isDestructive: $0.data.isDestructive
                )
            }

            menuViewController.updateMenuActions(menuActions)
        }
    }
}

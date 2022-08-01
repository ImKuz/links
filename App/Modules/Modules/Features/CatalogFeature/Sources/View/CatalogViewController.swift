import IdentifiedCollections
import ComposableArchitecture
import UIKit
import Models
import Combine
import Foundation

final class CatalogViewController: UICollectionViewController {

    private let store: Store<CatalogState, CatalogAction>
    private let viewStore: ViewStore<CatalogState, CatalogAction>
    private let rowMenuActionsProvider: CatalogRowMenuActionsProvider
    private let catalogUpdatePublisher: AnyPublisher<Void, Never>

    private var cancellables = [AnyCancellable]()
    private var currentItems = IdentifiedArrayOf<CatalogItem>()

    // MARK: - Init

    init(
        store: Store<CatalogState, CatalogAction>,
        rowMenuActionsProvider: CatalogRowMenuActionsProvider,
        catalogUpdatePublisher: AnyPublisher<Void, Never>
    ) {
        self.store = store
        self.viewStore = ViewStore(store)
        self.rowMenuActionsProvider = rowMenuActionsProvider
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
        collectionView.backgroundColor = .secondarySystemBackground
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
    }

    private func setupLeftButton(_ config: CatalogState.ButtonConfig?) {
        if let  config = config {
            navigationItem.leftBarButtonItem = makeBarButton(config: config)
        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }

    private func setupRightButton(_ config: CatalogState.ButtonConfig?) {
        if let  config = config {
            navigationItem.rightBarButtonItem = makeBarButton(config: config)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    private func makeBarButton(config: CatalogState.ButtonConfig) -> UIBarButtonItem {
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

    private func apllyDiff(newItems: IdentifiedArrayOf<CatalogItem>) {
        guard !isItemsEqual(current: currentItems, new: newItems) else { return }

        let diff = newItems.difference(from: currentItems)

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

        if insertIndexPaths.count > removeIndexPaths.count {
            collectionView.reloadData()
        } else {
            collectionView.performBatchUpdates {
                collectionView.deleteItems(at: removeIndexPaths)
                collectionView.insertItems(at: insertIndexPaths)
            }
        }
    }

    private func isItemsEqual(
        current: IdentifiedArrayOf<CatalogItem>,
        new: IdentifiedArrayOf<CatalogItem>
    ) -> Bool {
        zip(current, new).allSatisfy { $0 == $1 }
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
        let actions = rowMenuActionsProvider.acitons(state: viewStore.state, indexPath: indexPath)
        let state = CatalogRowDataMapper.map(item: item, actions: actions)

        cell.asyncActionsProvider = self
        cell.set(
            store: store.scope(
                state: { _ in state },
                action: {
                    CatalogAction.rowAction(id: item.id, action: $0)
                }
            )
        )

        return cell
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let item = currentItems[indexPath.row]
        viewStore.send(.rowAction(id: item.id, action: .tap))
    }

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
}

extension CatalogViewController: CatalogRowCellAsyncAcitonsProvider {

    func catalogRowRequestsAsyncActions(
        id: CatalogRowState.ID,
        completion: (([CatalogState.RowMenuAction]) -> ())?
    ) {
        rowMenuActionsProvider.asyncActions(id: id, state: viewStore.state) {
            completion?($0)
        }
    }
}

import IdentifiedCollections
import ComposableArchitecture
import UIKit
import Models
import Combine
import Foundation

final class CatalogViewController: UICollectionViewController {

    private let store: Store<CatalogState, CatalogAction>
    private let viewStore: ViewStore<CatalogState, CatalogAction>

    private var cancellables = [AnyCancellable]()
    private var currentItems = IdentifiedArrayOf<CatalogItem>()

    // MARK: - Init

    init(store: Store<CatalogState, CatalogAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
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
        guard let config = config else { return }
        navigationItem.leftBarButtonItem = makeBarButton(
            config: config,
            action: .init { [weak self] _ in
                self?.viewStore.send(.leftButtonTap)
            }
        )
    }

    private func setupRightButton(_ config: CatalogState.ButtonConfig?) {
        guard let config = config else { return }
        navigationItem.rightBarButtonItem = makeBarButton(
            config: config,
            action: .init { [weak self] _ in
                self?.viewStore.send(.rightButtonTap)
            }
        )
    }

    private func makeBarButton(config: CatalogState.ButtonConfig, action: UIAction) -> UIBarButtonItem {
        var image: UIImage?

        if let imageName = config.systemImageName {
            image = UIImage(systemName: imageName)
        }

        return .init(
            title: config.title,
            image: image,
            primaryAction: action,
            menu: nil
        )
    }

    private func apllyDiff(newItems: IdentifiedArrayOf<CatalogItem>) {
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

        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: removeIndexPaths)
            collectionView.insertItems(at: insertIndexPaths)
        }
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

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
        let state = CatalogRowDataMapper.map(item)

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

        viewStore.send(
            .rowAction(
                id: item.id,
                action: .onTap
            )
        )
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

    // MARK: - Selectors

    @objc
    private func leftButtonTap() {
        viewStore.send(.leftButtonTap)
    }

    @objc
    private func rightButtonTap() {
        viewStore.send(.rightButtonTap)
    }
}

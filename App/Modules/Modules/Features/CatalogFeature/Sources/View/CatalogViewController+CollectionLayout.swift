import UIKit

extension CatalogViewController {

    func makeCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(100)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = .init(
            top: 8,
            leading: 16,
            bottom: 8,
            trailing: 16
        )

        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(100)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        // Section
        let section = NSCollectionLayoutSection(group: group)

        return UICollectionViewCompositionalLayout(section: section)
    }
}

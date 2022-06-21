import UIKit

protocol CatalogRowMenuActionsProvider {
    func acitons(state: CatalogState, indexPath: IndexPath) -> [CatalogState.RowMenuAction]
}

final class CatalogRowMenuActionsProviderImpl: CatalogRowMenuActionsProvider {

    private let env: CatalogEnv

    init(env: CatalogEnv) {
        self.env = env
    }

    func acitons(state: CatalogState, indexPath: IndexPath) -> [CatalogState.RowMenuAction] {
        var menuActions = [CatalogState.RowMenuAction]()
        let item = state.items[indexPath.row]

        if case .link = item.content {
            menuActions.append(
                .init(
                    iconName: "doc.on.doc",
                    title: "Copy link",
                    action: .copy
                )
            )
        }

        if env.permissions.contains(.favorites) {
            let action: CatalogState.RowMenuAction

            if item.isFavorite {
                action = .init(
                    iconName: "star.slash",
                    title: "Remove from favorites",
                    action: .setIsFavorite(false)
                )
            } else {
                action = .init(
                    iconName: "star",
                    title: "Add to favorites",
                    action: .setIsFavorite(true)
                )
            }

            menuActions.append(action)
        }

        if env.permissions.contains(.modify) {
            menuActions.append(
                .init(
                    iconName: "trash",
                    title: "Delete",
                    action: .delete,
                    isDestructive: true
                )
            )
        }

        return menuActions
    }
}

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

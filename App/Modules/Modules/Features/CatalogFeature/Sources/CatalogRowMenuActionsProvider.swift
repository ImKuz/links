import UIKit

protocol CatalogRowMenuActionsProvider {
    func asyncActions(
        id: CatalogRowState.ID,
        state: CatalogState,
        completion: @escaping ([CatalogState.RowMenuAction]) -> ()
    )

    func acitons(state: CatalogState, indexPath: IndexPath) -> [CatalogState.RowMenuAction]
}

final class CatalogRowMenuActionsProviderImpl: CatalogRowMenuActionsProvider {

    private let env: CatalogEnv

    init(env: CatalogEnv) {
        self.env = env
    }

    func asyncActions(
        id: CatalogRowState.ID,
        state: CatalogState,
        completion: @escaping ([CatalogState.RowMenuAction]) -> ()
    ) {
        guard let item = state.items[id: id] else { return completion([]) }

        var actions = [CatalogState.RowMenuAction]()

        if case .link = item.content {
            switch env.linkTapAction {
            case .follow:
                actions.append(
                    .init(
                        iconName: "doc.on.doc",
                        title: "Copy link",
                        action: .copy
                    )
                )
            case .copy:
                actions.append(
                    .init(
                        iconName: "link",
                        title: "Follow link",
                        action: .follow
                    )
                )
            }
        }

        completion(actions)
    }

    func acitons(state: CatalogState, indexPath: IndexPath) -> [CatalogState.RowMenuAction] {
        var menuActions = [CatalogState.RowMenuAction]()
        let item = state.items[indexPath.row]

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

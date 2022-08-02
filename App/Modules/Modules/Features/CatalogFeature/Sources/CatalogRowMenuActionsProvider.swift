import UIKit

protocol CatalogRowMenuActionsProvider {
    func asyncActions(
        id: CatalogRowState.ID,
        state: CatalogState,
        completion: @escaping ([RowMenuAction]) -> ()
    )

    func acitons(state: CatalogState, indexPath: IndexPath) -> [RowMenuAction]
}

final class CatalogRowMenuActionsProviderImpl: CatalogRowMenuActionsProvider {

    private let env: CatalogEnv

    init(env: CatalogEnv) {
        self.env = env
    }

    func asyncActions(
        id: CatalogRowState.ID,
        state: CatalogState,
        completion: @escaping ([RowMenuAction]) -> ()
    ) {
        completion(
            env.configurableActions.compactMap(mapAction)
        )
    }

    func acitons(state: CatalogState, indexPath: IndexPath) -> [RowMenuAction] {
        var actions = [CatalogRowAction]()
        let item = state.items[indexPath.row]

        if env.permissions.contains(.favorites) {
            actions.append(
                .setIsFavorite(!item.isFavorite)
            )
        }

        if env.permissions.contains(.modify) {
            actions.append(.delete)
        }

        return actions.compactMap(mapAction)
    }

    private func mapAction(_ action: CatalogRowAction) -> RowMenuAction? {
        switch action {
        case .copy:
            return .init(
                iconName: "",
                title: "Copy link",
                action: action
            )

        case .follow:
            return .init(
                iconName: "link",
                title: "Open URL",
                action: action
            )

        case .edit:
            return .init(
                iconName: "square.and.pencil",
                title: "Edit",
                action: action
            )

        case .tap:
            return .none

        case .delete:
            return .init(
                iconName: "trash",
                title: "Delete",
                action: action,
                isDestructive: true
            )

        case .setIsFavorite(let isFavorite):
            return isFavorite
                ? .init(
                    iconName: "star.slash",
                    title: "Remove from favorites",
                    action: .setIsFavorite(false)
                )
                : .init(
                    iconName: "star",
                    title: "Add to favorites",
                    action: .setIsFavorite(true)
                )
        }
    }
}

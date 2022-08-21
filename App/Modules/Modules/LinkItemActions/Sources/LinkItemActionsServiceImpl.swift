import CatalogSource
import Combine
import Models
import ToolKit
import SharedHelpers

final class LinkItemActionsServiceImpl {

    private let catalogSource: CatalogSource
    private let actionHandler: LinkItemActionsHandler

    init(
        catalogSource: CatalogSource,
        actionHandler: LinkItemActionsHandler
    ) {
        self.catalogSource = catalogSource
        self.actionHandler = actionHandler
    }
}

// MARK: - LinkItemActionsService

extension LinkItemActionsServiceImpl: LinkItemActionsService {

    func actions(itemID: LinkItem.ID, shouldShowEditAction: Bool) async throws -> [LinkItemAction.WithData] {
        try await Publishers
            .Zip(isItemPersisted(id: itemID), catalogSource.isItemFavorite(id: itemID))
            .map { args in
                let (isFavorite, isPersisted) = args

                var actions: [LinkItemAction] = [
                    .copy, .open
                ]

                if shouldShowEditAction {
                    actions.append(.edit)
                }

                let favoritesAction: LinkItemAction = isFavorite
                    ? .removeFormFavorties
                    : .addToFavorites

                if isPersisted {
                    actions.append(contentsOf: [
                        favoritesAction,
                        .delete
                    ])
                }

                return Self.enrichActions(actions, itemId: itemID)
            }
            .eraseToAnyPublisher()
            .async()
    }

    private func isItemPersisted(id: LinkItem.ID) -> AnyPublisher<Bool, AppError> {
        guard catalogSource.isPersistable else {
            return Just(false)
                .setFailureType(to: AppError.self)
                .eraseToAnyPublisher()
        }

        return catalogSource.contains(itemId: id)
    }

    private static func enrichActions(
        _ actions: [LinkItemAction],
        itemId: LinkItem.ID
    ) -> [LinkItemAction.WithData] {
        actions.map {
            let label: LinkItemAction.Data.Label
            var isDestructive = false

            switch $0 {
            case .open:
                label = ("Open Link", "link")
            case .edit:
                label = ("Edit", "square.and.pencil")
            case .delete:
                label = ("Delete", "trash")
                isDestructive = true
            case .copy:
                label = ("Copy", "doc.on.doc")
            case .addToFavorites:
                label = ("Add to favorites", "star")
            case .removeFormFavorties:
                label = ("Remove from favorites", "star.slash")
            }

            return $0.withData(
                .init(
                    itemId: itemId,
                    label: label,
                    isDestructive: isDestructive
                )
            )
        }
    }
}

// MARK: - LinkItemActionsHandler

extension LinkItemActionsServiceImpl: LinkItemActionsHandler {

    func handle(
        _ actionWithData: LinkItemAction.WithData
    ) -> AnyPublisher<LinkItemAction.WithData, AppError> {
        actionHandler.handle(actionWithData)
    }
}

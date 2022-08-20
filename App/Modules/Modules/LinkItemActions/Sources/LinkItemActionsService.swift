import Combine
import ToolKit
import Models

public protocol LinkItemActionsService: LinkItemActionsHandler {

    func actions(
        itemID: LinkItem.ID,
        shouldShowEditAction: Bool
    ) async throws -> [LinkItemAction.WithData]
}


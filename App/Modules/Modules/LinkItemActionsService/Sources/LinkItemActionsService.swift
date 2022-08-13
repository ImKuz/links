import Combine
import ToolKit
import Models

public protocol LinkItemActionsService {

    func handle(action: LinkItemAction.WithData) -> AnyPublisher<LinkItemAction.WithData, AppError>

    func commonActions(itemID: LinkItem.ID) -> [LinkItemAction.WithData]
    func asyncActions(itemID: LinkItem.ID) -> AnyPublisher<[LinkItemAction.WithData], AppError>
}


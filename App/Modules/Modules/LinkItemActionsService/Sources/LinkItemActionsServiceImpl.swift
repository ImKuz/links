import CatalogSource
import Combine
import Models
import SharedInterfaces
import ToolKit

final class LinkItemActionsServiceImpl: LinkItemActionsService {

    private let catalogSource: CatalogSource
    private let router: Router

    init(catalogSource: CatalogSource, router: Router) {
        self.catalogSource = catalogSource
        self.router = router
    }

    // MARK: - LinkItemActionsService

    func handle(_ actionWithData: LinkItemAction.WithData) -> AnyPublisher<LinkItemAction.WithData, AppError> {
        isItemPersisted(id: actionWithData.data.itemId)
            .withUnretained(self)
            .flatMap { $0.handle(actionWithData, isItemPersisted: $1) }
            .eraseToAnyPublisher()
    }

    func asyncActions(itemID: LinkItem.ID) -> AnyPublisher<[LinkItemAction.WithData], AppError> {
        fatalError()
    }

    func commonActions(itemID: LinkItem.ID) -> [LinkItemAction.WithData] {
        var actions = [LinkItemAction.WithData]()



        return actions
    }

    // MARK: - Private methods

    private func isItemPersisted(id: LinkItem.ID) -> AnyPublisher<Bool, AppError> {
        guard catalogSource.isPersistable else { return Just(false).eraseToAnyPublisher() }
        return catalogSource.contains(itemId: id)
    }

    private func handle(
        _ actionWithData: LinkItemAction.WithData,
        isItemPersisted: Bool
    ) -> AnyPublisher<LinkItemAction.WithData, AppError> {
        let itemId = actionWithData.data.itemId
        fatalError()
    }
}

import Models
import ComposableArchitecture
import ToolKit
import Combine
import CatalogSource
import UIKit
import LinkItemActions
import UIComponents

final class EditLinkEnvImpl: EditLinkEnv {

    private let catalogSource: CatalogSource
    private let initialItem: LinkItem
    private let linkItemActionsService: LinkItemActionsService

    let menuViewController = MenuViewController()
    let onFinishSubject = PassthroughSubject<Void, Never>()

    init(
        catalogSource: CatalogSource,
        initialItem: LinkItem,
        linkItemActionsService: LinkItemActionsService
    ) {
        self.catalogSource = catalogSource
        self.initialItem = initialItem
        self.linkItemActionsService = linkItemActionsService
    }

    func validateState(_ state: EditLinkState) -> Effect<Set<EditLinkState.ValidateableField>, Never> {
        var invalidFields = Set<EditLinkState.ValidateableField>()

        if state.name.isEmpty {
            invalidFields.insert(.name)
        }

        if !state.urlString.isLink {
            invalidFields.insert(.url)
        }

        state.queryParams.enumerated().forEach { index, item in
            if item.key.isEmpty {
                invalidFields.insert(.key(index: index))
            }

            if item.value.isEmpty {
                invalidFields.insert(.value(index: index))
            }
        }

        return Effect(value: invalidFields)
    }

    func followLink(state: EditLinkState) -> Effect<Void, AppError> {
        if let url = URL(string: state.urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return Effect(value: ())
        } else {
            return Effect(error: .businessLogic("URL is inavlid"))
        }
    }

    func expandQueryItemValue(value: String) -> Effect<String, Never> {
        return .none
    }

    func done(state: EditLinkState) -> Effect<Void, AppError> {
        catalogSource
            .add(item: LinkItem(
                id: UUID().uuidString,
                name: state.name,
                urlString: state.urlString
            ))
            .handleEvents(receiveOutput: { [weak self] in
                self?.onFinishSubject.send()
            })
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    }

    func handle(action: LinkItemAction.WithData) -> Effect<LinkItemAction.WithData, AppError> {
        linkItemActionsService
            .handle(action)
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    }

    @MainActor
    func actionsProvider(itemId: LinkItem.ID) async -> [LinkItemAction.WithData] {
        do {
            return try await linkItemActionsService.actions(itemID: itemId, shouldShowEditAction: false)
        } catch {
            // TODO: Error handling
            return []
        }
    }

    private func map(state: EditLinkState) -> LinkItem {
        .init(
            id: initialItem.id,
            name: state.name,
            urlString: state.urlString,
            isFavorite: initialItem.isFavorite
        )
    }
}

import Models
import ComposableArchitecture
import ToolKit
import Combine
import CatalogSource
import UIKit
import LinkItemActions
import UIComponents
import FeatureSupport

final class EditLinkEnvImpl: EditLinkEnv {

    private let catalogSource: CatalogSource
    private let initialItem: LinkItem
    private let linkItemActionsService: LinkItemActionsService
    private let featureResolver: FeatureResolver
    private let router: Router

    let menuViewController = MenuViewController()
    let onFinishSubject = PassthroughSubject<Void, Never>()

    init(
        catalogSource: CatalogSource,
        initialItem: LinkItem,
        linkItemActionsService: LinkItemActionsService,
        featureResolver: FeatureResolver,
        router: Router
    ) {
        self.catalogSource = catalogSource
        self.initialItem = initialItem
        self.linkItemActionsService = linkItemActionsService
        self.featureResolver = featureResolver
        self.router = router
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

    func openLink(state: EditLinkState) -> Effect<Void, AppError> {
        if let url = URL(string: state.urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return Effect(value: ())
        } else {
            return Effect(error: .businessLogic("URL is inavlid"))
        }
    }

    func expandQueryItemValue(value: String) -> Effect<String, Never> {
        let interface = featureResolver.resolve(feature: TextEditorFeatureInterface.self, input: value)

        router.presentView(view: interface.view)

        return interface
            .onFinishPublisher
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.dismissPresetnedView()
            })
            .eraseToEffect()
    }

    func close() {
        onFinishSubject.send()
    }

    func dismissPresetnedView() {
        router.dismiss(isAnimated: true)
    }

    func save(state: EditLinkState) -> Effect<Void, AppError> {
        catalogSource
            .fetchItem(itemId: state.itemId)
            .withUnretained(self)
            .flatMap { ref, persistedItem -> AnyPublisher<Void, AppError>  in
                if let persistedItem = persistedItem {
                    return ref.catalogSource
                        .modify(item: ref.map(state: state, isFavorites: persistedItem.isFavorite))
                        .eraseToAnyPublisher()
                } else {
                    let linkItem = ref.map(state: state, isFavorites: false)

                    if linkItem.isEmpty {
                        return Just(()).setFailureType(to: AppError.self).eraseToAnyPublisher()
                    }

                    return ref.catalogSource
                        .add(item: ref.map(state: state, isFavorites: false))
                        .eraseToAnyPublisher()
                }
            }
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

    private func map(state: EditLinkState, isFavorites: Bool) -> LinkItem {
        .init(
            id: state.itemId,
            name: state.name,
            urlString: state.urlString,
            isFavorite: isFavorites
        )
    }
}

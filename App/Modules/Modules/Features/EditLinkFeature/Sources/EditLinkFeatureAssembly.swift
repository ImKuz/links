import ComposableArchitecture
import Database
import Swinject
import ToolKit
import FeatureSupport
import SwiftUI
import LinkItemActions

public struct EditLinkFeatureAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {

        let factory: (Resolver, EditLinkFeatureInterface.Input) -> EditLinkFeatureInterface = { resolver, input in
            let navigationController = UINavigationController()

            let router = RouterImpl(navigationController: navigationController)

            let environment = EditLinkEnvImpl(
                catalogSource: input.catalogSource,
                initialItem: input.item,
                linkItemActionsService: resolver.resolve(
                    LinkItemActionsService.self,
                    arguments: input.catalogSource,
                    input.router
                )!,
                featureResolver: resolver.resolve(FeatureResolver.self)!,
                router: router
            )

            let store = Store<EditLinkState, EditLinkAction>(
                initialState: EditLinkState(
                    itemId: input.item.id,
                    name: input.item.name,
                    urlStringComponents: .deconstructed(from: input.item.urlString)
                ),
                reducer: editLinkReducer,
                environment: environment
            )

            var view = EditLinkView(store: store)

            view.actionsProvider = { [weak environment] itemId in
                await environment?.actionsProvider(itemId: itemId) ?? []
            }

            view.menuViewControllerProvider = { [weak environment] in
                environment?.menuViewController
            }

            router.pushToView(view: view)
            let navigationHolder = UINavigationControllerHolder(navigationController: navigationController)
            let anyView = AnyView(navigationHolder)

            return EditLinkFeatureInterface(
                view: anyView,
                onFinishPublisher: environment.onFinishSubject.eraseToAnyPublisher()
            )
        }

        container.register(
            EditLinkFeatureInterface.self,
            factory: factory
        )
    }
}

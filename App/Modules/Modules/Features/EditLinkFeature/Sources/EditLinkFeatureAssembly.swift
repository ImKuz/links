import ComposableArchitecture
import Database
import Swinject
import ToolKit
import FeatureSupport
import SwiftUI
import LinkItemActionsService

public struct EditLinkFeatureAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {

        let factory: (Resolver, EditLinkFeatureInterface.Input) -> EditLinkFeatureInterface = { resolver, input in
            let environment = EditLinkEnvImpl(
                catalogSource: input.catalogSource,
                initialItem: input.item,
                linkItemActionsService: resolver.resolve(
                    LinkItemActionsService.self,
                    arguments: input.catalogSource,
                    input.router
                )!
            )

            let store = Store<EditLinkState, EditLinkAction>(
                initialState: EditLinkState(
                    name: input.item.name,
                    urlStringComponents: .deconstructed(from: input.item.urlString)
                ),
                reducer: editLinkReducer,
                environment: environment
            )

            var view = EditLinkView(store: store)
            view.linkItemActionsMenuViewDelegate = environment
            let anyView = AnyView(view)

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

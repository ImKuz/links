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
                    itemId: input.item.id,
                    name: input.item.name,
                    urlStringComponents: .deconstructed(from: input.item.urlString)
                ),
                reducer: editLinkReducer,
                environment: environment
            )

            return EditLinkFeatureInterface(
                view: AnyView(EditLinkView(store: store)),
                onFinishPublisher: environment.onFinishSubject.eraseToAnyPublisher()
            )
        }

        container.register(
            EditLinkFeatureInterface.self,
            factory: factory
        )
    }
}

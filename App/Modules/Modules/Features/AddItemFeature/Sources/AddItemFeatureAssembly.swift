import ComposableArchitecture
import Database
import Swinject
import ToolKit
import SharedInterfaces
import SwiftUI

public struct AddItemFeatureAssembly: Assembly {

    private let container: Container

    public init(container: Container) {
        self.container = container
    }

    // MARK: - Public methods

    public func assemble(container: Container) {

        let factory: (Resolver, AddItemFeatureInterface.Input) -> AddItemFeatureInterface = { _, input in
            let environment = AddItemEnvImpl(catalogSource: input)

            let store = Store<AddItemState, AddItemAction>(
                initialState: .initial,
                reducer: addItemReducer,
                environment: environment
            )

            let view = AnyView(AddItemView(store: store))

            return AddItemFeatureInterface(
                view: view,
                onFinishPublisher: environment.onFinishSubject.print().eraseToAnyPublisher()
            )
        }

        container.register(
            AddItemFeatureInterface.self,
            factory: factory
        )
    }
}

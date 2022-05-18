import Swinject
import SharedEnv
import SharedInterfaces
import ComposableArchitecture
import ToolKit
import SwiftUI

public struct RootFeatureAssembly: Assembly {

    private let container: Container

    public init(container: Container) {
        self.container = container
    }

    public func assemble(container: Container) {
        let tabs = [
            Tab(type: .local, name: "Local", iconName: "list.dash")
        ]

        let store: Store<RootState, RootAction> = .init(
            initialState: .init(remoteSourceData: .default, tabs: tabs),
            reducer: RootReducerFactory.make(),
            environment: SystemEnv.make(environment: RootEnv())
        )

        let view = RootView(
            tabViewsProvider: RootTabViewsProviderImpl(container: container),
            store: store
        )

        container.register(RootFeatureInterface.self) { _ in
            RootFeatureInterface(view: AnyView(view))
        }
    }
}

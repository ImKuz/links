import Swinject
import SharedInterfaces
import ComposableArchitecture
import ToolKit
import SwiftUI

public struct RootFeatureAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        let tabs = [
            Tab(type: .local, name: "Local", iconName: "list.dash"),
            Tab(type: .remote, name: "Remote", iconName: "globe"),
        ]

        let store: Store<RootState, RootAction> = .init(
            initialState: .init(tabs: tabs),
            reducer: RootReducerFactory.make(),
            environment: RootEnv()
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

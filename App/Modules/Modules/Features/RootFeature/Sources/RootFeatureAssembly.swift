import Swinject
import FeatureSupport
import ComposableArchitecture
import ToolKit
import SwiftUI
import Constants

public struct RootFeatureAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        let tabs = [
            Tab(type: .favorites, name: "Favorites", iconName: "star"),
            Tab(type: .local, name: "Snippets", iconName: "note.text"),
            Tab(type: .remote, name: "Network", iconName: "globe"),
            Tab(type: .settings, name: "Settings", iconName: "gearshape"),
        ]

        let selectedTabTag = UserDefaults.standard.string(forKey: UserDefaultsKeys.Settings.defaultTabTag)
        let selectedTabIndex = tabs.firstIndex { $0.type.rawValue == selectedTabTag } ?? 0

        let store: Store<RootState, RootAction> = .init(
            initialState: .init(selectedTab: selectedTabIndex, tabs: tabs),
            reducer: rootReducer,
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

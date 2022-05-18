import Swinject
import SharedEnv
import SharedInterfaces
import ComposableArchitecture
import ToolKit
import SwiftUI

public protocol RootFeatureAssembly: Assembly {

    static func previewMock(isPhone: Bool) -> AnyView
}

public struct RootFeatureAssemblyImpl: RootFeatureAssembly {

    private let container: Container

    public init(container: Container) {
        self.container = container
    }

    public func assemble(container: Container) {
        let tabs = [
            Tab(type: .local, name: "Local", iconName: "list.dash")
        ]

        let initialTab = tabs.first!

        let store: Store<RootState, RootAction> = .init(
            initialState: .init(
                remoteSourceData: .default,
                tabs: tabs,
                selectedTab: initialTab
            ),
            reducer: RootReducerFactory.make(),
            environment: SystemEnv.make(environment: RootEnv())
        )

        container.register(RootViewHolder.self) { resolver in
            switch DeviceIdiomProvider.shared.deviceType {
            case .phone:
                #if os(iOS)
                return RootView(
                    tabViewsProvider: RootTabViewsProviderImpl(container: container),
                    store: store,
                    viewStore: .init(store)
                )
                #else
                fatalError("Uncompatible arch")
                #endif
            case .pad, .mac:
                return RootMacView(
                    tabViewsProvider: RootTabViewsProviderImpl(container: container),
                    store: store,
                    viewStore: .init(store)
                )
            }

        }
    }

    public static func previewMock(isPhone: Bool) -> AnyView {
        let tabs = [
            Tab(type: .local, name: "Local", iconName: "list.dash")
        ]

        let initialTab = tabs.first!

        let store: Store<RootState, RootAction> = .init(
            initialState: .init(
                remoteSourceData: .default,
                tabs: tabs,
                selectedTab: initialTab
            ),
            reducer: RootReducerFactory.make(),
            environment: SystemEnv.make(environment: RootEnv())
        )

        switch DeviceIdiomProvider.shared.deviceType {
        case .phone:
            #if os(iOS)
            return AnyView(
                RootView(
                     tabViewsProvider: RootTabViewsProviderMock(),
                     store: store,
                     viewStore: .init(store)
                 )
            )
            #else
                fatalError("Uncompatible arch")
            #endif
        case .mac, .pad:
            return AnyView(
                RootMacView(
                    tabViewsProvider: RootTabViewsProviderMock(),
                    store: store,
                    viewStore: .init(store)
                ).previewLayout(.fixed(width: 640, height: 480))
            )
        }
    }
}

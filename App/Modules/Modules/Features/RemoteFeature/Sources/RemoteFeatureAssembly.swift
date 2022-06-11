import ComposableArchitecture
import Swinject
import SharedInterfaces
import UIKit
import SwiftUI
import ToolKit
import CatalogServer

public struct RemoteFeatureAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(RemoteFeatureInterface.self) { resolver in

            let navigationController = UINavigationController()
            let router = RouterImpl(navigationController: navigationController)

            let enviroment = RemoteEnvImpl(
                router: router,
                catalogServer: container.resolve(CatalogServer.self)!,
                container: container
            )

            let store = Store(
                initialState: .init(),
                reducer: remoteReducer,
                environment: enviroment
            )

            let view = RemoteView(store: store)
            router.pushToView(view: view, isAnimated: false)
            let navigationHolder = UINavigationControllerHolder(navigationController: navigationController)
            let anyView = AnyView(navigationHolder)

            return .init(view: anyView)
        }
    }
}

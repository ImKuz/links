import ComposableArchitecture
import Swinject
import SharedInterfaces
import UIKit
import SwiftUI
import ToolKit

public struct RemoteFeatureAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(RemoteFeatureInterface.self) { resolver in

            let navigationController = UINavigationController()
            let router = RouterImpl(navigationController: navigationController)
            let enviroment = RemoteEnvImpl(router: router)

            let store = Store(
                initialState: .init(),
                reducer: remoteReducer,
                environment: enviroment
            )

            let view = RemoteView(store: store)
            let anyView = AnyView(view)

            router.pushToView(view: view, isAnimated: false)
            return .init(view: anyView)
        }
    }
}

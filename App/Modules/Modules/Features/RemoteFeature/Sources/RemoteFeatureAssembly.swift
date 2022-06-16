import ComposableArchitecture
import Swinject
import SharedInterfaces
import UIKit
import SwiftUI
import ToolKit
import CatalogServer
import Foundation
import Constants

public struct RemoteFeatureAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(RemoteFeatureInterface.self) { resolver in
            let navigationController = UINavigationController()
            let router = RouterImpl(navigationController: navigationController)
            let userDefaults = UserDefaults.standard

            var initialState = RemoteState()

            Self.enrichInitalState(state: &initialState, using: userDefaults)

            let enviroment = RemoteEnvImpl(
                router: router,
                catalogServer: container.resolve(CatalogServer.self)!,
                container: container,
                userDefaults: userDefaults,
                initialState: initialState
            )

            let store = Store(
                initialState: initialState,
                reducer: remoteReducer,
                environment: enviroment
            )

            let view = RemoteView(store: store)
            router.pushToView(view: view, isAnimated: false)
            let navigationHolder = UINavigationControllerHolder(navigationController: navigationController)
            let anyView = AnyView(navigationHolder)

            enviroment.handleInitialState(initialState)
            return .init(view: anyView)
        }
    }

    private static func enrichInitalState(state: inout RemoteState, using userDefaults: UserDefaults) {
        if let value = userDefaults.value(forKey: UserDefaultsKeys.remoteOption) as? Int {
            state.defaultOption = RemoteState.Option(rawValue: value)
        }

        if
            let host = userDefaults.value(forKey: UserDefaultsKeys.lastConnectedHost) as? String,
            let port = userDefaults.value(forKey: UserDefaultsKeys.lastConnectedPort) as? Int
        {
            state.lastConnectedCredentials = .init(host: host, port: port)
        }
    }

    private static func getStoredOpton(using userDefaults: UserDefaults) -> RemoteState.Option? {
        if let value = userDefaults.value(forKey: UserDefaultsKeys.remoteOption) as? Int {
            return RemoteState.Option(rawValue: value)
        } else {
            return nil
        }
    }
}

import ComposableArchitecture
import Database
import FeatureSupport
import SharedHelpers
import SwiftUI
import Swinject
import ToolKit

public struct SettingsFeatureAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(SettingsFeatureInterface.self) { resolver in
            let settingsHelper = resolver.resolve(SettingsHelper.self)!
            let database = resolver.resolve(DatabaseService.self)!

            let navigationController = UINavigationController()
            let router = RouterImpl(navigationController: navigationController)

            let env = SettingsEnvImpl(
                settings: settingsHelper,
                userDefaults: .standard,
                databaseService: database
            )

            let state = makeDefaultState(settings: settingsHelper)

            let store = Store<SettingsState, SettingsAction>(
                initialState: state,
                reducer: settingsReducer,
                environment: env
            )

            let view = SettingsView(store: store)
            router.pushToView(view: view, isAnimated: false)
            let navigationHolder = UINavigationControllerHolder(navigationController: navigationController)
            let anyView = AnyView(navigationHolder)

            return SettingsFeatureInterface(view: anyView)
        }
    }

    // MARK: - Helpers

    private func makeDefaultState(settings: SettingsHelper) -> SettingsState {

        let tabOptions: [SettingsOption] = [
            .init(title: "Favorites", tag: "favorites"),
            .init(title: "Snippets", tag: "snippets"),
            .init(title: "Network", tag: "remote"),
        ]

        let linkTapBehaviours: [SettingsOption] = [
            .init(title: "Open link", tag: "open"),
            .init(title: "Copy link", tag: "copy"),
            .init(title: "Edit link", tag: "edit")
        ]

        let selectedTabOption = tabOptions
            .firstIndex { $0.tag == settings.tabTag } ?? 0

        let selectedLinkTapBehaviourOption = linkTapBehaviours
            .firstIndex { $0.tag == settings.linkTapBehaviour } ?? 0

        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        return .init(
            tabOptions: tabOptions,
            linkTapBehaviours: linkTapBehaviours,
            appVersion: appVersion ?? "N/A",
            selectedTabOption: selectedTabOption,
            selectedLinkTapBehaviourOption: selectedLinkTapBehaviourOption
        )
    }
}

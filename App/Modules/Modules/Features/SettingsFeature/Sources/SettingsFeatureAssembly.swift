import ComposableArchitecture
import FeatureSupport
import SharedHelpers
import Swinject
import Database
import SwiftUI

public struct SettingsFeatureAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(SettingsFeatureInterface.self) { resolver in
            let settingsHelper = resolver.resolve(SettingsHelper.self)!
            let database = resolver.resolve(DatabaseService.self)!

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
            return SettingsFeatureInterface(view: AnyView(view))
        }
    }

    // MARK: - Helpers

    private func makeDefaultState(settings: SettingsHelper) -> SettingsState {

        let tabOptions: [SettingsOption] = [
            .init(title: "Favorites", tag: "favorites"),
            .init(title: "Snippets", tag: "local"),
            .init(title: "Network", tag: "remote"),
        ]

        let linkTapBehaviours: [SettingsOption] = [
            .init(title: "Open the link", tag: "open"),
            .init(title: "Copy the link", tag: "copy"),
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

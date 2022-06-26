import Swinject

enum SettingsHelperRegistrar {

    static func register(using container: Container) {
        container.register(SettingsHelper.self) { _ in
            SettingsHelperImpl(
                userDefaults: .standard,
                defaultTabTag: defineDefaultTabTag(),
                defaultLinkTapBehaviour: defineDefaultLinkTapBehaviour()
            )
        }
    }

    private static func defineDefaultTabTag() -> String {
        "favorites"
    }

    private static func defineDefaultLinkTapBehaviour() -> String {
        "copy"
    }
}

import Swinject

enum SettingsHelperRegistrar {

    static func register(using container: Container) {
        container
            .register(SettingsHelper.self) { _ in
                SettingsHelperImpl(
                    userDefaults: .standard,
                    defaultTabTag: defineDefaultTabTag(),
                    defaultLinkTapBehaviour: defineDefaultLinkTapBehaviour()
                )
            }
            .inObjectScope(.container)
    }

    private static func defineDefaultTabTag() -> String {
        "snippets"
    }

    private static func defineDefaultLinkTapBehaviour() -> String {
        "copy"
    }
}

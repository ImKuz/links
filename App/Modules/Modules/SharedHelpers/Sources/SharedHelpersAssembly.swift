import Swinject

public struct SharedHelpersAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        SettingsHelperRegistrar.register(using: container)
    }
}

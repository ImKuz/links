import Swinject

public struct SharedHelpersAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        SettingsHelperRegistrar.register(using: container)

        container.register(URLOpener.self) { _ in
            URLOpenerImpl()
        }

        container.register(TextEncoder.self) { _ in
            TextEncoderImpl()
        }

        container.register(TextDecoder.self) { _ in
            TextDecoderImpl()
        }
    }
}

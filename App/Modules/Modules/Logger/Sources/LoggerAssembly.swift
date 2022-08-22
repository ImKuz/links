import Swinject
import Logging

public struct LoggerAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(Logger.self) { _ in
            let logger = Logging.Logger(label: "com.links-app")
            return LoggerImpl(logger: logger, label: nil)
        }
    }
}

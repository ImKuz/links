import Swinject
import Logging

public struct LoggerAssembly: Assembly {

    public func assemble(container: Container) {
        container.register(Logger.self) { _ in
            let logger = Logging.Logger(label: "com.copy-pasta.app")
            return LoggerImpl(logger: logger, label: nil)
        }
    }
}

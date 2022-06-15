import Logging

final class LoggerImpl: Logger {

    let logger: Logging.Logger
    let label: String?

    init(logger: Logging.Logger, label: String? = nil) {
        self.logger = logger
        self.label = label
    }

    // MARK: - Logger

    func log(text: String, level: LogLevel) {
        logger.log(level: mapLogLevel(level), message(text))
    }

    func channel(label: String) -> Logger {
        return LoggerImpl(logger: logger, label: label)
    }

    // MARK: - Private methods

    private func message(_ string: String) -> Logging.Logger.Message {
        var message = ""

        if let label = label {
            message = "[\(label)] | "
        }

        message.append(contentsOf: string)
        return .init(stringLiteral: message)
    }

    private func mapLogLevel(_ logLevel: LogLevel) -> Logging.Logger.Level {
        switch logLevel {
        case .info:
            return .info
        case .debug:
            return .debug
        case .warning:
            return .warning
        case .error:
            return .error
        }
    }
}

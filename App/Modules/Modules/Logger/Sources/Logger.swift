import ToolKit

public protocol Logger {

    func log(text: String, level: LogLevel)
    func channel(label: String) -> Logger
}

public extension Logger {

    func info(_ message: String) {
        log(text: message, level: .info)
    }

    func debug(_ message: String) {
        log(text: message, level: .debug)
    }

    func warning(_ message: String) {
        log(text: message, level: .warning)
    }

    func error(_ message: String) {
        log(text: message, level: .error)
    }

    func log(_ error: AppError) {
        log(text: error.description, level: .error)
    }
}

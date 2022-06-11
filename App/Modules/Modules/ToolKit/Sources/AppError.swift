public enum AppError: Error, Equatable {
    case common(description: String?)
    case mapping(description: String?)
    case businessLogic(String)

    public var description: String {
        switch self {
        case .common(let description):
            return description ?? "Common error"
        case .mapping(let description):
            return description ?? "Unable to map data"
        case .businessLogic(let string):
            return string
        }
    }
}

public enum AppError: Error, Equatable {
    case common(description: String?)
    case mapping(description: String?)
}

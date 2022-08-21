public enum TextEncoding {
    case base64
}

public enum TextKind {
    case raw
    case encoded(TextEncoding)
}

public struct Text {

    public typealias Kind = TextKind
    public typealias Encoding = TextEncoding

    public let kind: Kind
    public let string: String

    public init(kind: TextKind, string: String) {
        self.kind = kind
        self.string = string
    }

    public static func raw(_ string: String) -> Self {
        .init(kind: .raw, string: string)
    }
}

// MARK: - Helpers

public extension Text {

    var isEmpty: Bool { string.isEmpty }
}

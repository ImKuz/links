public enum TextEncoding {
    case base64
}

public enum TextKind {
    case raw
    case encoded(TextEncoding)
}

public struct Text {

    public let kind: TextKind
    public let string: String

    public init(kind: TextKind, string: String) {
        self.kind = kind
        self.string = string
    }

    public static func raw(_ string: String) -> Self {
        .init(kind: .raw, string: string)
    }
}

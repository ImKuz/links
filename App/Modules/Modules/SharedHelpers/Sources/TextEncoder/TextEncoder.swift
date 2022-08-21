import Models
import Foundation

public protocol TextEncoder {
    func encode(string: String, using encoding: Text.Encoding) -> Text
}

public extension TextEncoder {
    func encode(text: Text, using encoding: Text.Encoding) -> Text {
        encode(string: text.string, using: encoding)
    }
}

final class TextEncoderImpl: TextEncoder {

    // MARK: - Init

    public init() {}

    // MARK: - TextEncoder

    func encode(string: String, using encoding: Text.Encoding) -> Text {
        switch encoding {
        case .base64:
            return base64Encoding(string)
        }
    }

    // MARK: - Private methods

    private func base64Encoding(_ string: String) -> Text {
        let encodedString = Data(string.utf8).base64EncodedString()
        return Text(kind: .encoded(.base64), string: encodedString)
    }
}

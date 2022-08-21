import Models
import Foundation

public protocol TextDecoder {
    func decode(text: Text) -> Text?
}

final class TextDecoderImpl: TextDecoder {

    // MARK: - Init

    public init() {}

    // MARK: - TextEncoder

    func decode(text: Text) -> Text? {
        switch text.kind {
        case .encoded(let encoding):
            switch encoding {
            case .base64:
                return base64Decoding(text)
            }
        case .raw:
            return text
        }
    }

    // MARK: - Private methods

    private func base64Decoding(_ text: Text) -> Text? {
        guard
            let data = Data(base64Encoded: text.string),
            let decodedString = String(data: data, encoding: .utf8)
        else {
            return nil
        }

        return .raw(decodedString)
    }
}

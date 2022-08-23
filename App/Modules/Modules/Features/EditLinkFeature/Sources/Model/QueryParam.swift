struct QueryParam: Equatable {
    var key = ""
    var value = ""

    var isEmpty: Bool {
        key.isEmpty && value.isEmpty
    }

    var asURLEncodedString: String? {
        guard !isEmpty else { return "" }
        guard !value.isEmpty else { return "\(key)" }

        // According to RFC3986 | https://www.rfc-editor.org/rfc/rfc3986#section-2.3
        let encodedValue = value.addingPercentEncoding(
            withAllowedCharacters: .alphanumerics.union(
                .init(charactersIn: "~-_.")
            )
        )

        return "\(key)=\(encodedValue ?? "")"
    }

    static var empty = Self(key: "", value: "")
}


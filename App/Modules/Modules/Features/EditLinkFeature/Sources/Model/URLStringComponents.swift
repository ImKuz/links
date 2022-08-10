struct URLStringComponents: Equatable {

    var urlStringWithoutParams: String
    var queryParams: [QueryParam]

    init(
        urlStringWithoutParams: String = "",
        queryParams: [QueryParam] = []
    ) {
        self.urlStringWithoutParams = urlStringWithoutParams
        self.queryParams = queryParams
    }
}


// MARK: - URL Construction

extension URLStringComponents {

    func constructUrlString() -> String {
        let paramsString = queryParams
            .enumerated()
            .reduce(into: "") { string, element in
                let (index, param) = element
                if index != 0 { string += "&" }
                string += param.asURLEncodedString ?? ""
            }

        return paramsString.isEmpty
            ? urlStringWithoutParams
            : "\(urlStringWithoutParams)?\(paramsString)"
    }

    static func deconstructed(from urlString: String) -> Self {
        guard !urlString.isEmpty else { return .init() }
        let parts = urlString.components(separatedBy: "?")

        let urlStringWithoutParams = parts[0]

        guard parts.count > 1 else {
            return .init(urlStringWithoutParams: urlStringWithoutParams, queryParams: [])
        }

        let paramsString = parts[1]

        return .init(
            urlStringWithoutParams: urlStringWithoutParams,
            queryParams: queryParams(from: paramsString)
        )
    }

    // MARK: Helpers

    private static func queryParams(from string: String) -> [QueryParam] {
        guard !string.isEmpty else { return [] }

        var result = [QueryParam]()
        var isCaputuringKey = true
        var isCapturingValue = false
        var isCapturing: Bool { isCaputuringKey || isCapturingValue }

        var key = ""
        var value = ""

        let appendCurrentParam: () -> () = {
            let value = value.removingPercentEncoding ?? value
            result.append(QueryParam(key: key, value: value))
        }

        for char in string {
            switch char {
            case "&":
                appendCurrentParam()
                key = ""
                value = ""
                isCaputuringKey = true
                isCapturingValue = false
            case "=":
                isCaputuringKey = false
                isCapturingValue = true
            default:
                if isCaputuringKey {
                    key.append(char)
                } else if isCapturingValue {
                    value.append(char)
                }
            }
        }

        if isCapturing {
            appendCurrentParam()
        }

        return result
    }
}

// MARK: - QueryParams edit

extension URLStringComponents {

    mutating func updateQueryParam(key: String, at index: Int) {
        let param = queryParams[index]
        queryParams[index] = .init(key: key, value: param.value)
    }

    mutating func updateQueryParam(value: String, at index: Int) {
        let param = queryParams[index]
        queryParams[index] = .init(key: param.key, value: value)
    }
}

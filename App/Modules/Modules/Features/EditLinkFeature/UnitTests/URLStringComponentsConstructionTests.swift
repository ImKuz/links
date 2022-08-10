import XCTest

@testable import EditLinkFeature

final class URLStringComponentsConstructionTests: XCTestCase {

    /// This list describes test cases for ensuring correct String to URL construction/deconstruction.
    static let testCaseList = [
        (
            "singleQueryParam",
            urlString("?foo=bar"),
            URLStringComponents(params: [
                .init(key: "foo", value: "bar"),
            ])
        ),
        (
            "multipleQueryParam",
            urlString("?k1=v1&k2=v2&k3=v3"),
            URLStringComponents(params: [
                .init(key: "k1", value: "v1"),
                .init(key: "k2", value: "v2"),
                .init(key: "k3", value: "v3"),
            ])
        ),
        (
            "nestedUrls",
            urlString("?k1=https%3A%2F%2Fya.ru%3Ffoo%3Dbar&k2=v2"),
            URLStringComponents(params: [
                .init(key: "k1", value: "https://ya.ru?foo=bar"),
                .init(key: "k2", value: "v2"),
            ])
        ),
        (
           "emptyKey_leading_inMultipleParams",
           urlString("?k1=v1&=v2"),
           URLStringComponents(params: [
               .init(key: "k1", value: "v1"),
               .init(key: "", value: "v2"),
           ])
       ),
        (
           "emptyKey_trailing_inMultipleParams",
           urlString("?=v1&k2=v2"),
           URLStringComponents(params: [
               .init(key: "", value: "v1"),
               .init(key: "k2", value: "v2"),
           ])
       ),
        (
           "emptyValue_trailing_inMultipleParams",
           urlString("?k1=v1&k2="),
           URLStringComponents(params: [
               .init(key: "k1", value: "v1"),
               .init(key: "k2", value: ""),
           ])
       ),
        (
           "emptyValue_leading_inMultipleParams",
           urlString("?k1=&k2=v2"),
           URLStringComponents(params: [
               .init(key: "k1", value: ""),
               .init(key: "k2", value: "v2"),
           ])
       )
    ]

    // MARK: - Test methods

    func test__ensureAllCases_URLConstruction() {
        for testCase in Self.testCaseList {
            let (name, urlString, components) = testCase
            let result = components.constructUrlString()
            if urlString != result {
                XCTFail("Unable to construct expected URL: '\(urlString)' | got: \(result) | case: \(name)")
            }
        }
    }

    func test__ensureAllCases_URLDeconstruction() {
        for testCase in Self.testCaseList {
            let (name, urlString, components) = testCase
            let result = URLStringComponents.deconstructed(from: urlString)
            if components != result {
                XCTFail("Unable to deconstruct URL | case: \(name)")
            }
        }
    }

    // MARK: - Helpers

    static let urlStringWithoutParams = "https://foo.com"

    private static func urlString(_ queryParamsString: String) -> String {
        "\(urlStringWithoutParams)\(queryParamsString)"
    }

    typealias TestableCase = (
        name: String,
        urlString: String,
        components: URLStringComponents
    )
}

private extension URLStringComponents {

    init(params: [QueryParam]) {
        self.init(
            urlStringWithoutParams: URLStringComponentsConstructionTests.urlStringWithoutParams,
            queryParams: params
        )
    }
}

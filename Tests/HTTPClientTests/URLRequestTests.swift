@testable import HTTPClient
import XCTest

final class URLRequestTests: XCTestCase {

    let request: URLRequest = .init(url: apiURL)

    func testAppendingHeaders() {
        var expectedValue = enUSLanguageKey

        let test1Request = request.appending(
            headers: [
                acceptLanguageKey: enUSLanguageKey,
            ]
        )

        let newValue1 = test1Request.allHTTPHeaderFields![acceptLanguageKey]!

        // Test adding initial value //
        XCTAssert(newValue1 == enUSLanguageKey)

        expectedValue = enUSLanguageKey + ",en"

        let test2Request = test1Request.appending(
            headers: [
                acceptLanguageKey: "en"
            ]
        )

        let newValue2 = test2Request.allHTTPHeaderFields![acceptLanguageKey]!

        // Test adding second value //
        XCTAssert(newValue2 == expectedValue, "'\(newValue2)' != '\(expectedValue)'")
    }

    func testSettingHeaders() {
        let testRequest = request.setting(
            headers: [
                acceptLanguageKey: enUSLanguageKey,
            ]
        )

        XCTAssert(testRequest.allHTTPHeaderFields![acceptLanguageKey] == enUSLanguageKey)

        let test2Request = testRequest.setting(
            headers: [
                acceptLanguageKey: frCALanguageKey
            ]
        )

        XCTAssert(test2Request.allHTTPHeaderFields![acceptLanguageKey] == frCALanguageKey)
    }
}

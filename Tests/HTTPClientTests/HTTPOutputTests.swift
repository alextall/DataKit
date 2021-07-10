@testable import HTTPClient
import XCTest

final class HTTPOutputTests: XCTestCase {

    func testOutputModel() {
        let output = HTTPOutput.body(data: data!, response: response)

        XCTAssert(output.data == data)
        XCTAssert(output.response.url == response.url)
        XCTAssert(output.response.statusCode == response.statusCode)
    }
}

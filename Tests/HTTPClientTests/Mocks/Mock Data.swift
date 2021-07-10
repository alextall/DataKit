import Foundation
import XCTest

var apiURL: URL { URL(string: "https://example.com/")! }

var acceptLanguageKey: String { "Accept-Language" }
var enUSLanguageKey: String { "en-US" }
var frCALanguageKey: String { "fr-CA" }

var data: Data? {
    let jsonString = "{\"testing\":true}"
    return jsonString.data(using: .utf8)
}

var response: HTTPURLResponse {
    HTTPURLResponse(
        url: apiURL,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
}

var successfulRequestHandler = { (request: URLRequest) throws -> (HTTPURLResponse, Data?) in
    let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    return (response, data)
}

var failingRequestHandler = { (request: URLRequest) throws -> (HTTPURLResponse, Data?) in
    throw URLError(.badServerResponse)
}

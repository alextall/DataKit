@testable import HTTPClient
import XCTest
import Combine

final class HTTPClientTests: XCTestCase {

    var client: TestingClient!
    var apiURL: URL { URL(string: "https://example.com/")! }
    var expectation: XCTestExpectation!

    lazy var data: Data? = {
        let jsonString = "{\"title\":\"testing\"}"
        return jsonString.data(using: .utf8)
    }()
    lazy var successfulRequestHandler = { (request: URLRequest) -> (HTTPURLResponse, Data?) in
        XCTAssertEqual(request.url, self.apiURL, "URL should not change")

        let response = HTTPURLResponse(url: self.apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, self.data)
    }

    var bag = Set<AnyCancellable>()

    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)

        client = .init(session: urlSession, baseURL: apiURL)
        expectation = expectation(description: "Expectation")
    }

    func testGetRequest() {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url, self.apiURL, "URL should not change")

            let response = HTTPURLResponse(url: self.apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, self.data)
        }

        let request = URLRequest(url: apiURL)

        client.get(request)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssertNil(error)
                }

                self.expectation.fulfill()
            } receiveValue: { output in
                XCTAssertEqual(output.response.url, self.apiURL, "URL should not change")
                XCTAssertEqual(output.response.statusCode, 200, "Status Code should not change")
                XCTAssertEqual(output.data, self.data, "Data object should not change.")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testGetURL() {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url, self.apiURL, "URL should not change")

            let response = HTTPURLResponse(url: self.apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, self.data)
        }

        client.get(apiURL)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssertNil(error)
                }

                self.expectation.fulfill()
            } receiveValue: { output in
                XCTAssertEqual(output.response.url, self.apiURL, "URL should not change")
                XCTAssertEqual(output.response.statusCode, 200, "Status Code should not change")
                XCTAssertEqual(output.data, self.data, "Data object should not change.")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testGetComponents() {
        let pathComponent = "about"
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url, self.apiURL.appendingPathComponent(pathComponent))

            let response = HTTPURLResponse(url: self.apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, self.data)
        }

        client.get(pathComponent)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssert(false, "\(error.localizedDescription)")
                }

                self.expectation.fulfill()
            } receiveValue: { output in
                XCTAssertEqual(output.response.url, self.apiURL, "URL should not change")
                XCTAssertEqual(output.response.statusCode, 200, "Status Code should not change")
                XCTAssertEqual(output.data, self.data, "Data object should not change.")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testGetFailure() {
        MockURLProtocol.requestHandler = { request in
            throw URLError(.badServerResponse)
        }

        client.get(apiURL)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(false)
                case .failure(_):
                    XCTAssertTrue(true)
                }

                self.expectation.fulfill()
            } receiveValue: { _ in
                XCTAssertFalse(true, "Failure should not send a value")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }
}

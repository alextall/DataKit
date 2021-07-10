@testable import HTTPClient
import XCTest
import Combine

final class HTTPClientTests: XCTestCase {

    var client: TestingClient!
    var expectation: XCTestExpectation!

    var bag = Set<AnyCancellable>()

    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)

        client = .init(session: urlSession, baseURL: apiURL)
        expectation = expectation(description: "Expectation")
    }

    // MARK: - GET

    func testGetRequest() {
        MockURLProtocol.requestHandler = successfulRequestHandler

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
                XCTAssertEqual(output.response.url, apiURL, "URL should not change")
                XCTAssertEqual(output.response.statusCode, 200, "Status Code should not change")
                XCTAssertEqual(output.data, data, "Data object should not change.")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testGetURL() {
        MockURLProtocol.requestHandler = successfulRequestHandler

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
                XCTAssertEqual(output.response.url, apiURL, "URL should not change")
                XCTAssertEqual(output.response.statusCode, 200, "Status Code should not change")
                XCTAssertEqual(output.data, data, "Data object should not change.")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testGetComponents() {
        let pathComponent = "about"
        MockURLProtocol.requestHandler = successfulRequestHandler

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
                XCTAssertEqual(output.response.url, apiURL.appendingPathComponent(pathComponent), "URL should include path component: \"\(pathComponent)\"")
                XCTAssertEqual(output.response.statusCode, 200, "Status Code should not change")
                XCTAssertEqual(output.data, data, "Data object should not change.")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testGetFailure() {
        MockURLProtocol.requestHandler = failingRequestHandler

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

    // MARK: - POST

    func testPOSTRequest() {
        MockURLProtocol.requestHandler = successfulRequestHandler

        let request = URLRequest(url: apiURL)

        client.post(request)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssertNil(error)
                }

                self.expectation.fulfill()
            } receiveValue: { output in
                XCTAssertEqual(output.response.url, apiURL, "URL should not change")
                XCTAssertEqual(output.response.statusCode, 200, "Status Code should not change")
                XCTAssertEqual(output.data, data, "Data object should not change.")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testPOSTURL() {
        MockURLProtocol.requestHandler = successfulRequestHandler

        client.post(apiURL)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssertNil(error)
                }

                self.expectation.fulfill()
            } receiveValue: { output in
                XCTAssertEqual(output.response.url, apiURL, "URL should not change")
                XCTAssertEqual(output.response.statusCode, 200, "Status Code should not change")
                XCTAssertEqual(output.data, data, "Data object should not change.")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testPOSTComponents() {
        let pathComponent = "about"
        MockURLProtocol.requestHandler = successfulRequestHandler

        client.post(pathComponent)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssert(false, "\(error.localizedDescription)")
                }

                self.expectation.fulfill()
            } receiveValue: { output in
                XCTAssertEqual(output.response.url, apiURL.appendingPathComponent(pathComponent), "URL should include path component: \"\(pathComponent)\"")
                XCTAssertEqual(output.response.statusCode, 200, "Status Code should not change")
                XCTAssertEqual(output.data, data, "Data object should not change.")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testPOSTFailure() {
        MockURLProtocol.requestHandler = failingRequestHandler

        client.post(apiURL)
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

    // MARK: - PUT

    func testPUTRequest() {
        MockURLProtocol.requestHandler = successfulRequestHandler

        let request = URLRequest(url: apiURL)

        client.put(request)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssertNil(error)
                }

                self.expectation.fulfill()
            } receiveValue: { output in
                XCTAssertEqual(output.response.url, apiURL, "URL should not change")
                XCTAssertEqual(output.response.statusCode, 200, "Status Code should not change")
                XCTAssertEqual(output.data, data, "Data object should not change.")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testPUTURL() {
        MockURLProtocol.requestHandler = successfulRequestHandler

        client.put(apiURL)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssertNil(error)
                }

                self.expectation.fulfill()
            } receiveValue: { output in
                XCTAssertEqual(output.response.url, apiURL, "URL should not change")
                XCTAssertEqual(output.response.statusCode, 200, "Status Code should not change")
                XCTAssertEqual(output.data, data, "Data object should not change.")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testPUTComponents() {
        let pathComponent = "about"
        MockURLProtocol.requestHandler = successfulRequestHandler

        client.put(pathComponent)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssert(false, "\(error.localizedDescription)")
                }

                self.expectation.fulfill()
            } receiveValue: { output in
                XCTAssertEqual(output.response.url, apiURL.appendingPathComponent(pathComponent), "URL should include path component: \"\(pathComponent)\"")
                XCTAssertEqual(output.response.statusCode, 200, "Status Code should not change")
                XCTAssertEqual(output.data, data, "Data object should not change.")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testPUTFailure() {
        MockURLProtocol.requestHandler = failingRequestHandler

        client.put(apiURL)
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

    // MARK: - DELETE

    func testDELETERequest() {
        MockURLProtocol.requestHandler = successfulRequestHandler

        let request = URLRequest(url: apiURL)

        client.delete(request)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssertNil(error)
                }

                self.expectation.fulfill()
            } receiveValue: { output in
                XCTAssertEqual(output.response.url, apiURL, "URL should not change")
                XCTAssertEqual(output.response.statusCode, 200, "Status Code should not change")
                XCTAssertEqual(output.data, data, "Data object should not change.")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testDELETEURL() {
        MockURLProtocol.requestHandler = successfulRequestHandler

        client.delete(apiURL)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssertNil(error)
                }

                self.expectation.fulfill()
            } receiveValue: { output in
                XCTAssertEqual(output.response.url, apiURL, "URL should not change")
                XCTAssertEqual(output.response.statusCode, 200, "Status Code should not change")
                XCTAssertEqual(output.data, data, "Data object should not change.")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testDELETEComponents() {
        let pathComponent = "about"
        MockURLProtocol.requestHandler = successfulRequestHandler

        client.delete(pathComponent)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(let error):
                    XCTAssert(false, "\(error.localizedDescription)")
                }

                self.expectation.fulfill()
            } receiveValue: { output in
                XCTAssertEqual(output.response.url, apiURL.appendingPathComponent(pathComponent), "URL should include path component: \"\(pathComponent)\"")
                XCTAssertEqual(output.response.statusCode, 200, "Status Code should not change")
                XCTAssertEqual(output.data, data, "Data object should not change.")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testDELETEFailure() {
        MockURLProtocol.requestHandler = failingRequestHandler

        client.delete(apiURL)
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

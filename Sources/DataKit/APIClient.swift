import Combine
import Foundation

public protocol APIClient {
    var session: URLSession { get }
    var configuration: URLSessionConfiguration { get }

    var cachePolicy: URLRequest.CachePolicy { get }
    var timeout: TimeInterval { get }
    var customHeaders: [String: String] { get }
}

public extension APIClient {
    func publisher(_ request: URLRequest) -> AnyPublisher<HTTPOutput, URLError> {
        return session.dataTaskPublisher(for: request)
            .map { data, response in
                (data, response as! HTTPURLResponse)
            }.eraseToAnyPublisher()
    }

    func publisher(_ url: URL) -> AnyPublisher<HTTPOutput, URLError> {
        return session.dataTaskPublisher(for: url)
            .map { data, response in
                (data, response as! HTTPURLResponse)
            }.eraseToAnyPublisher()
    }

    func newRequest(_ url: URL,
                    cachePolicy: URLRequest.CachePolicy? = nil,
                    timeoutInterval: TimeInterval? = nil,
                    headers: [String: String] = [:]) -> URLRequest {
        return URLRequest(url: url,
                          cachePolicy: cachePolicy ?? self.cachePolicy,
                          timeoutInterval: timeoutInterval ?? timeout)
            .appending(headers: customHeaders.merging(headers,
                                                      uniquingKeysWith: { $1 }))
    }
}

extension APIClient {
    func execute(_ request: URLRequest) -> Future<HTTPOutput, URLError> {
        return Future { promise in
            _ = self.publisher(request)
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        return promise(.failure(error))
                    }
                }) { value in
                    promise(.success(value))
                }
        }
    }
}

public extension APIClient {
    func get(_ url: URL) -> AnyPublisher<HTTPOutput, URLError> {
        let request = newRequest(url)
        return get(request)
    }

    func get(_ request: URLRequest) -> AnyPublisher<HTTPOutput, URLError> {
        var request = request.appending(headers: customHeaders)
        request.httpMethod = "GET"
        return execute(request).eraseToAnyPublisher()
    }

    func post(_ url: URL) -> AnyPublisher<HTTPOutput, URLError> {
        let request = newRequest(url)
        return post(request)
    }

    func post(_ request: URLRequest) -> AnyPublisher<HTTPOutput, URLError> {
        var request = request.appending(headers: customHeaders)
        request.httpMethod = "POST"
        return execute(request).eraseToAnyPublisher()
    }
}

public extension APIClient {
    typealias HTTPOutput = (data: Data, response: HTTPURLResponse)
}

extension URLRequest {
    func appending(headers: [String: String]) -> URLRequest {
        var request = self
        for (_, (key, value)) in headers.enumerated() {
            request.addValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}

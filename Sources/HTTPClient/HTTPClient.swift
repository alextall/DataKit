import Combine
import Foundation

/// A protocol that provides simple networking.
public protocol HTTPClient {
    var session: URLSession { get }
    var baseURL: URL { get }

    var cachePolicy: URLRequest.CachePolicy { get }
    var timeout: TimeInterval { get }
    var customHeaders: [String: String] { get }
}

public extension HTTPClient {
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

public enum HTTPError: Error {
    case urlError(URLError)
    case unknown(Error)
}

extension HTTPClient {
    /// Execute the provided `URLRequest`
    /// - Parameter request: A `URLRequest` to execute
    func execute(_ request: URLRequest) -> Future<HTTPOutput, HTTPError> {
        return Future { promise in
            self.session.dataTask(with: request,
                                  completionHandler: { data, response, error in
                                      if let error = error as? URLError {
                                          promise(.failure(.urlError(error)))
                                      } else if let error = error {
                                          promise(.failure(.unknown(error)))
                                      }
                                      let data = data ?? Data()
                                      let response = response as! HTTPURLResponse
                                      promise(.success(.init(data: data, response: response)))
            }).resume()
        }
    }
}

// MARK: - GET

public extension HTTPClient {
    /// Execute a `GET` HTTP request with the provided `URL`
    /// - Parameter url: A `URL` object to use for the request
    func get(_ url: URL) -> AnyPublisher<HTTPOutput, HTTPError> {
        let request = newRequest(url)
        return get(request)
    }

    /// Execute a `GET` HTTP request with the provided `URLRequest`
    /// - Parameter request: A `URLRequest` to execute
    func get(_ request: URLRequest) -> AnyPublisher<HTTPOutput, HTTPError> {
        var request = request.appending(headers: customHeaders)
        request.httpMethod = "GET"
        return execute(request).eraseToAnyPublisher()
    }
}

// MARK: - POST

public extension HTTPClient {
    /// Execute a `POST` HTTP request with the provided `URL`
    /// - Parameter url: A `URL` object to use for the request
    func post(_ url: URL) -> AnyPublisher<HTTPOutput, HTTPError> {
        let request = newRequest(url)
        return post(request)
    }

    /// Execute a `POST` HTTP request with the provided `URLRequest`
    /// - Parameter request: A `URLRequest` to execute
    func post(_ request: URLRequest) -> AnyPublisher<HTTPOutput, HTTPError> {
        var request = request.appending(headers: customHeaders)
        request.httpMethod = "POST"
        return execute(request).eraseToAnyPublisher()
    }
}

// MARK: - PUT

public extension HTTPClient {
    /// Execute a `PUT` HTTP request with the provided `URL`
    /// - Parameter url: A `URL` object to use for the request
    func put(_ url: URL) -> AnyPublisher<HTTPOutput, HTTPError> {
        let request = newRequest(url)
        return post(request)
    }

    /// Execute a `PUT` HTTP request with the provided `URLRequest`
    /// - Parameter request: A `URLRequest` to execute
    func put(_ request: URLRequest) -> AnyPublisher<HTTPOutput, HTTPError> {
        var request = request.appending(headers: customHeaders)
        request.httpMethod = "PUT"
        return execute(request).eraseToAnyPublisher()
    }
}

// MARK: - DELETE

public extension HTTPClient {
    /// Execute a `DELETE` HTTP request with the provided `URL`
    /// - Parameter url: A `URL` object to use for the request
    func delete(_ url: URL) -> AnyPublisher<HTTPOutput, HTTPError> {
        let request = newRequest(url)
        return post(request)
    }

    /// Execute a `DELETE` HTTP request with the provided `URLRequest`
    /// - Parameter request: A `URLRequest` to execute
    func delete(_ request: URLRequest) -> AnyPublisher<HTTPOutput, HTTPError> {
        var request = request.appending(headers: customHeaders)
        request.httpMethod = "DELETE"
        return execute(request).eraseToAnyPublisher()
    }
}

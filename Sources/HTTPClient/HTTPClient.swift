
import Combine
import Foundation

/// A protocol that provides simple networking.
public protocol HTTPClient {
    var session: URLSession { get }
    var baseURL: URL { get }
}

public extension HTTPClient {
    func newRequest(_ url: URL) -> URLRequest {
        return URLRequest(url: url)
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
                                    let response = response as! HTTPURLResponse
                                    if let data = data {
                                        promise(.success(.body(data: data, response: response)))
                                    }
                                    promise(.success(.empty(response)))
            }).resume()
        }
    }
}

// MARK: - GET

public extension HTTPClient {
    /// Execute a `GET` HTTP request at the given endpoint
    /// - Paramenter url: A `String` to be appended to the base URL
    func get(_ pathComponents: String) -> Future<HTTPOutput, HTTPError> {
        let url = baseURL.appendingPathComponent(pathComponents)
        return get(url)
    }
    
    /// Execute a `GET` HTTP request with the provided `URL`
    /// - Parameter url: A `URL` object to use for the request
    func get(_ url: URL) -> Future<HTTPOutput, HTTPError> {
        let request = newRequest(url)
        return get(request)
    }
    
    /// Execute a `GET` HTTP request with the provided `URLRequest`
    /// - Parameter request: A `URLRequest` to execute
    func get(_ request: URLRequest) -> Future<HTTPOutput, HTTPError> {
        var request = request
        request.httpMethod = "GET"
        return execute(request)
    }
}

// MARK: - POST

public extension HTTPClient {
    /// Execute a `POST` HTTP request at the given endpoint
    /// - Paramenter url: A `String` to be appended to the base URL
    func post(_ pathComponents: String) -> Future<HTTPOutput, HTTPError> {
        let url = baseURL.appendingPathComponent(pathComponents)
        return post(url)
    }
    
    /// Execute a `POST` HTTP request with the provided `URL`
    /// - Parameter url: A `URL` object to use for the request
    func post(_ url: URL) -> Future<HTTPOutput, HTTPError> {
        let request = newRequest(url)
        return post(request)
    }
    
    /// Execute a `POST` HTTP request with the provided `URLRequest`
    /// - Parameter request: A `URLRequest` to execute
    func post(_ request: URLRequest) -> Future<HTTPOutput, HTTPError> {
        var request = request
        request.httpMethod = "POST"
        return execute(request)
    }
}

// MARK: - PUT

public extension HTTPClient {
    /// Execute a `PUT` HTTP request at the given endpoint
    /// - Paramenter url: A `String` to be appended to the base URL
    func put(_ pathComponents: String) -> Future<HTTPOutput, HTTPError> {
        let url = baseURL.appendingPathComponent(pathComponents)
        return put(url)
    }
    
    /// Execute a `PUT` HTTP request with the provided `URL`
    /// - Parameter url: A `URL` object to use for the request
    func put(_ url: URL) -> Future<HTTPOutput, HTTPError> {
        let request = newRequest(url)
        return post(request)
    }
    
    /// Execute a `PUT` HTTP request with the provided `URLRequest`
    /// - Parameter request: A `URLRequest` to execute
    func put(_ request: URLRequest) -> Future<HTTPOutput, HTTPError> {
        var request = request
        request.httpMethod = "PUT"
        return execute(request)
    }
}

// MARK: - DELETE

public extension HTTPClient {
    /// Execute a `DELETE` HTTP request at the given endpoint
    /// - Paramenter url: A `String` to be appended to the base URL
    func delete(_ pathComponents: String) -> Future<HTTPOutput, HTTPError> {
        let url = baseURL.appendingPathComponent(pathComponents)
        return delete(url)
    }
    
    /// Execute a `DELETE` HTTP request with the provided `URL`
    /// - Parameter url: A `URL` object to use for the request
    func delete(_ url: URL) -> Future<HTTPOutput, HTTPError> {
        let request = newRequest(url)
        return post(request)
    }
    
    /// Execute a `DELETE` HTTP request with the provided `URLRequest`
    /// - Parameter request: A `URLRequest` to execute
    func delete(_ request: URLRequest) -> Future<HTTPOutput, HTTPError> {
        var request = request
        request.httpMethod = "DELETE"
        return execute(request)
    }
}

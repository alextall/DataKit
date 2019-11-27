import Combine
import Foundation

public protocol HTTPClient {
    var session: URLSession { get }

    var cachePolicy: URLRequest.CachePolicy { get }
    var timeout: TimeInterval { get }
    var customHeaders: [String: String] { get }
}

public extension HTTPClient {
    func publisher(_ request: URLRequest) -> AnyPublisher<HTTPOutput, URLError> {
        return session.dataTaskPublisher(for: request)
            .map { data, response in
                .init(data: data, response: response as! HTTPURLResponse)
        }.eraseToAnyPublisher()
    }

    func publisher(_ url: URL) -> AnyPublisher<HTTPOutput, URLError> {
        return session.dataTaskPublisher(for: url)
            .map { data, response in
                .init(data: data, response:  response as! HTTPURLResponse)
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

extension HTTPClient {
    func execute(_ request: URLRequest) -> Future<HTTPOutput, URLError> {
        return Future { promise in
            self.session.dataTask(with: request,
                                  completionHandler: { data, response, error in
                                    if let error = error as? URLError {
                                        promise(.failure(error))
                                    }
                                    let data = data ?? Data()
                                    let response = response as! HTTPURLResponse
                                    promise(.success(.init(data: data, response: response)))
            }).resume()
        }
    }
}

public extension HTTPClient {
    func get(_ url: URL) -> AnyPublisher<HTTPOutput, URLError> {
        let request = newRequest(url)
        return get(request)
    }

    func get(_ request: URLRequest) -> AnyPublisher<HTTPOutput, URLError> {
        var request = request.appending(headers: customHeaders)
        request.httpMethod = "GET"
        return execute(request).eraseToAnyPublisher()
    }
}

public extension HTTPClient {
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

public extension HTTPClient {
    func put(_ url: URL) -> AnyPublisher<HTTPOutput, URLError> {
        let request = newRequest(url)
        return post(request)
    }

    func put(_ request: URLRequest) -> AnyPublisher<HTTPOutput, URLError> {
        var request = request.appending(headers: customHeaders)
        request.httpMethod = "PUT"
        return execute(request).eraseToAnyPublisher()
    }
}

public extension HTTPClient {
    func delete(_ url: URL) -> AnyPublisher<HTTPOutput, URLError> {
        let request = newRequest(url)
        return post(request)
    }

    func delete(_ request: URLRequest) -> AnyPublisher<HTTPOutput, URLError> {
        var request = request.appending(headers: customHeaders)
        request.httpMethod = "DELETE"
        return execute(request).eraseToAnyPublisher()
    }
}

public struct HTTPOutput {
    let data: Data
    let response: HTTPURLResponse
}

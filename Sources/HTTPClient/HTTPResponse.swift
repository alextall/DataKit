import Foundation

/// An object containing the `HTTPResponse` and the HTTP body returned.
public enum HTTPResponse {
    case body(data: Data, response: HTTPURLResponse)
    case empty(HTTPURLResponse)
    
    public var data: Data {
        switch self {
        case let .body(data, _):
            return data
        case let .empty(_, _):
            return Data()
        }
    }
    
    public var response: HTTPURLResponse {
        switch self {
        case let .body(_, response):
            return response
        case let .empty(response):
            return response
        }
    }
}

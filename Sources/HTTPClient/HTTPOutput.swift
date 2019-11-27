import Foundation

/// An object containing the `HTTPResponse` and the HTTP body returned.
public struct HTTPOutput {
    let data: Data
    let response: HTTPURLResponse
}

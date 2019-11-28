import Foundation

extension URLRequest {
    func appending(headers: [String: String]) -> URLRequest {
        var request = self
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        return request
    }

    func setting(headers: [String: String]) -> URLRequest {
        var request = self
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }
}

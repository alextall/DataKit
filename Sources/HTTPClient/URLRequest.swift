import Foundation

extension URLRequest {
    func appending(headers: [String: String]) -> URLRequest {
        var request = self
        for (_, (key, value)) in headers.enumerated() {
            request.addValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}

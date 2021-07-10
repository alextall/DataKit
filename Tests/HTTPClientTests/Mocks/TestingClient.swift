import Foundation
import HTTPClient

class TestingClient: HTTPClient {
    var session: URLSession
    var baseURL: URL

    init(session: URLSession,
         baseURL: URL = URL(string: "https://example.com")!) {
        self.session = session
        self.baseURL = baseURL
    }
}

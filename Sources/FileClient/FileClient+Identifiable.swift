import Foundation
import Combine

// MARK: - Saving

public extension FileClient {
    func save<T: Codable & Identifiable>(object: T) -> AnyPublisher<Void, FileClientError> where T.ID == UUID {
        save(object: object, filename: object.id.uuidString)
    }

    func save<T: Codable & Identifiable>(object: T) -> AnyPublisher<Void, FileClientError> where T.ID == String {
        save(object: object, filename: object.id)
    }

    func save<T: Codable & Identifiable>(object: T) -> AnyPublisher<Void, FileClientError> where T.ID == Int {
        save(object: object, filename: "\(object.id)")
    }
}

// MARK: - Fetching

public extension FileClient {
    func object<T: Codable & Identifiable>(of type: T.Type, with id: T.ID) -> AnyPublisher<T, FileClientError> where T.ID == UUID {
        object(of: type, from: id.uuidString)
    }

    func object<T: Codable & Identifiable>(of type: T.Type, with id: T.ID) -> AnyPublisher<T, FileClientError> where T.ID == String {
        object(of: type, from: id)
    }

    func object<T: Codable & Identifiable>(of type: T.Type, with id: T.ID) -> AnyPublisher<T, FileClientError> where T.ID == Int {
        object(of: type, from: "\(id)")
    }
}

// MARK: - Fetching

public extension FileClient {
    func objectMonitor<T: Codable & Identifiable>(of type: T.Type, with id: T.ID) -> AnyPublisher<T, FileClientError> where T.ID == UUID {
        objectMonitor(of: type, from: id.uuidString)
    }

    func objectMonitor<T: Codable & Identifiable>(of type: T.Type, with id: T.ID) -> AnyPublisher<T, FileClientError> where T.ID == String {
        objectMonitor(of: type, from: id)
    }

    func objectMonitor<T: Codable & Identifiable>(of type: T.Type, with id: T.ID) -> AnyPublisher<T, FileClientError> where T.ID == Int {
        objectMonitor(of: type, from: "\(id)")
    }
}

// MARK: - Deleting

public extension FileClient {
    func delete<T: Codable & Identifiable>(object: T) -> AnyPublisher<Void, FileClientError> where T.ID == UUID {
        delete(filename: object.id.uuidString)
    }

    func delete<T: Codable & Identifiable>(object: T) -> AnyPublisher<Void, FileClientError> where T.ID == String {
        delete(filename: object.id)
    }
}

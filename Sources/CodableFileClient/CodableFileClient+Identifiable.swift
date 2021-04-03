import Foundation
import Combine

// MARK: - Saving

public extension CodableFileClient {
    func save<T: Codable & Identifiable>(object: T) -> AnyPublisher<T, Error> where T.ID == UUID {
        save(object: object, filename: object.id.uuidString)
    }

    func save<T: Codable & Identifiable>(object: T) -> AnyPublisher<T, Error> where T.ID == String {
        save(object: object, filename: object.id)
    }

    func save<T: Codable & Identifiable>(object: T) -> AnyPublisher<T, Error> where T.ID == Int {
        save(object: object, filename: "\(object.id)")
    }
}

// MARK: - Fetching

public extension CodableFileClient {
    func object<T: Codable & Identifiable>(of type: T.Type, with id: T.ID) -> AnyPublisher<T, Error> where T.ID == UUID {
        object(of: type, from: id.uuidString)
    }

    func object<T: Codable & Identifiable>(of type: T.Type, with id: T.ID) -> AnyPublisher<T, Error> where T.ID == String {
        object(of: type, from: id)
    }

    func object<T: Codable & Identifiable>(of type: T.Type, with id: T.ID) -> AnyPublisher<T, Error> where T.ID == Int {
        object(of: type, from: "\(id)")
    }
}

// MARK: - Fetching

public extension CodableFileClient {
    func objectMonitor<T: Codable & Identifiable>(of type: T.Type, with id: T.ID) -> AnyPublisher<T, Error> where T.ID == UUID {
        objectMonitor(of: type, from: id.uuidString)
    }

    func objectMonitor<T: Codable & Identifiable>(of type: T.Type, with id: T.ID) -> AnyPublisher<T, Error> where T.ID == String {
        objectMonitor(of: type, from: id)
    }

    func objectMonitor<T: Codable & Identifiable>(of type: T.Type, with id: T.ID) -> AnyPublisher<T, Error> where T.ID == Int {
        objectMonitor(of: type, from: "\(id)")
    }
}

// MARK: - Deleting

extension CodableFileClient {
    func delete<T: Codable & Identifiable>(object: T) -> AnyPublisher<Void, Error> where T.ID == UUID {
        delete(filename: object.id.uuidString)
    }

    func delete<T: Codable & Identifiable>(object: T) -> AnyPublisher<Void, Error> where T.ID == String {
        delete(filename: object.id)
    }
}
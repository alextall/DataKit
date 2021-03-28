import Combine
import Foundation

final public class CodableFileClient {
    private let location: FileLocation

    public init(location: FileLocation = .local) {
        self.location = location
    }
}

// MARK: - Saving

public extension CodableFileClient {
    func save<T: Codable & Identifiable>(object: T, filename: String) -> AnyPublisher<T, Error> {
        Future { [encoder, location] promise in
            do {
                let data = try encoder.encode(object)
                try data.write(to: location.url
                                .appendingPathComponent(filename + ".json"),
                               options: [.atomic])
                promise(.success(object))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}

public extension CodableFileClient {
    func save<T: Codable & Identifiable>(object: T) -> AnyPublisher<T, Error> where T.ID == UUID {
        save(object: object, filename: object.id.uuidString)
    }
}

public extension CodableFileClient {
    func save<T: Codable & Identifiable>(object: T) -> AnyPublisher<T, Error> where T.ID == String {
        save(object: object, filename: object.id)
    }
}

// MARK: - Fetching

public extension CodableFileClient {
    func files() -> AnyPublisher<[URL], Error> {
        return Future { [fileManager, location] promise in
            do {
                let urls = try fileManager.contentsOfDirectory(at: location.url,
                                                               includingPropertiesForKeys: nil,
                                                               options: .skipsHiddenFiles)
                promise(.success(urls))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    func objects<T: Codable & Identifiable>(from files: [URL]) -> AnyPublisher<[T], Error> {
        Just(files)
            .tryMap { urls in
                try urls
                    .map { url in
                        try Data(contentsOf: url)
                    }
            }
            .flatMap(Publishers.Sequence.init(sequence:))
            .decode(type: T.self, decoder: decoder)
            .collect()
            .eraseToAnyPublisher()
    }

    func objects<T: Codable & Identifiable>(of type: T.Type) -> AnyPublisher<[T], Error> {
        files()
            .flatMap(objects(from:))
            .eraseToAnyPublisher()
    }
}

// MARK: - Deleting

public extension CodableFileClient {
    func delete(filename: String) -> AnyPublisher<(), Error> {
        Future { [fileManager, location] promise in
            do {
                try fileManager.removeItem(at: location.url(for: filename))
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}

//MARK: - Helpers

private extension CodableFileClient {
    var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        #if DEBUG
        encoder.outputFormatting = .prettyPrinted
        #endif
        return encoder
    }
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    var fileManager: FileManager {
        FileManager.default
    }
}

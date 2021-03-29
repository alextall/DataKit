import Combine
import Foundation

final public class CodableFileClient {
    private let location: FileLocation
    private var monitor: FolderMonitor

    public init(location: FileLocation) throws {

        var isDir: ObjCBool = true
        let locationExists = FileManager.default.fileExists(atPath: location.path,
                                                            isDirectory: &isDir)
        if !locationExists || !isDir.boolValue {
            try FileManager.default.createDirectory(at: location.url,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        }

        self.location = location

        do {
            monitor = try .init(url: location.url)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

// MARK: - Saving

public extension CodableFileClient {
    func save<T: Codable & Identifiable>(object: T, filename: String) -> AnyPublisher<T, Error> {
        Future { [encoder, location] promise in
            do {
                let data = try encoder.encode(object)
                try data.write(to: location.url(for: filename),
                               options: [.atomic])
                promise(.success(object))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    func save<T: Codable & Identifiable>(object: T) -> AnyPublisher<T, Error> where T.ID == UUID {
        save(object: object, filename: object.id.uuidString)
    }

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
        Publishers.Sequence<[URL], Error>(sequence: files)
            .tryMap { try Data(contentsOf: $0) }
            .decode(type: T.self, decoder: decoder)
            .collect()
            .eraseToAnyPublisher()
    }

    func objects<T: Codable & Identifiable>(of type: T.Type) -> AnyPublisher<[T], Error> {
        files()
            .flatMap(objects(from:))
            .eraseToAnyPublisher()
    }

    func objectMonitor<T: Codable & Identifiable>(of type: T.Type) -> AnyPublisher<[T], Error> {
        monitor.folderDidChange
            .setFailureType(to: Error.self)
            .flatMap({ [unowned self] _ in
                objects(of: type)
            })
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

    func delete<T: Codable & Identifiable>(object: T) -> AnyPublisher<(), Error> where T.ID == UUID {
        delete(filename: object.id.uuidString)
    }

    func delete<T: Codable & Identifiable>(object: T) -> AnyPublisher<(), Error> where T.ID == String {
        delete(filename: object.id)
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

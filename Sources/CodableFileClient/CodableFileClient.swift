import Combine
import Foundation

public final class CodableFileClient {
    private let location: FileLocation
    private var monitor: FolderMonitor

    public init(location: FileLocation) throws {
        #if DEBUG
        print("Using location: \(location.url)")
        #endif
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
    func save<T: Codable>(object: T, filename: String) -> AnyPublisher<T, Error> {
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
}

// MARK: - Fetching

public extension CodableFileClient {
    func file(for filename: String) -> AnyPublisher<URL, Never> {
        Just(location.url(for: filename))
            .eraseToAnyPublisher()
    }

    func object<T: Codable>(of type: T.Type, from filename: String) -> AnyPublisher<T, Error> {
        file(for: filename)
            .tryMap { try Data(contentsOf: $0) }
            .decode(type: type, decoder: decoder)
            .eraseToAnyPublisher()
    }

    func objectMonitor<T: Codable>(of type: T.Type, from filename: String) -> AnyPublisher<T, Error> {
        monitor.folderDidChange
            .setFailureType(to: Error.self)
            .flatMap { [unowned self] _ in
                object(of: T.self, from: filename)
            }
            .eraseToAnyPublisher()
    }
}

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

    func objects<T: Codable>(from files: [URL]) -> AnyPublisher<[T], Error> {
        Publishers.Sequence<[URL], Error>(sequence: files)
            .tryMap { try Data(contentsOf: $0) }
            .decode(type: T.self, decoder: decoder)
            .collect()
            .eraseToAnyPublisher()
    }

    func objects<T: Codable>(of _: T.Type) -> AnyPublisher<[T], Error> {
        files()
            .flatMap(objects(from:))
            .eraseToAnyPublisher()
    }

    func objectMonitor<T: Codable>(of type: T.Type) -> AnyPublisher<[T], Error> {
        monitor.folderDidChange
            .setFailureType(to: Error.self)
            .flatMap { [unowned self] _ in
                objects(of: type)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Deleting

public extension CodableFileClient {
    func delete(filename: String) -> AnyPublisher<Void, Error> {
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

// MARK: - Helpers

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

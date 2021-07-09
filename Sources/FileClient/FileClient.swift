import Combine
import Foundation
import os

public final class FileClient {
    private let location: FileLocation
    private let monitor: FolderMonitor

    public init(location: FileLocation) throws {
        #if DEBUG
        os_log("Using location: %@", location.path)
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

public extension FileClient {
    func save(data: Data, filename: String) -> AnyPublisher<Void, FileClientError> {
        Future { [location] promise in
            do {
                try data.write(to: location.url(for: filename),
                               options: [.atomic])
                promise(.success(()))
            } catch {
                promise(.failure(.writing(error)))
            }
        }
        .eraseToAnyPublisher()
    }

    func save<T: Codable>(object: T, filename: String) -> AnyPublisher<Void, FileClientError> {
        Future<Data, FileClientError> { [encoder] promise in
            do {
                let data = try encoder.encode(object)
                promise(.success(data))
            } catch {
                promise(.failure(.encoding(error)))
            }
        }
        .flatMap { [self] data in
            save(data: data, filename: filename)
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Fetching

public extension FileClient {
    func file(for filename: String) -> AnyPublisher<URL, Never> {
        Just(location.url(for: filename))
            .eraseToAnyPublisher()
    }

    func decode<T: Codable>(type: T.Type, from data: Data) -> AnyPublisher<T, FileClientError> {
        Future { [decoder] promise in
            do {
                let result = try decoder.decode(type, from: data)
                promise(.success(result))
            } catch {
                promise(.failure(.decoding(error)))
            }
        }
        .eraseToAnyPublisher()
    }

    func object<T: Codable>(of type: T.Type, from filename: String) -> AnyPublisher<T, FileClientError> {
        file(for: filename)
            .tryMap { try Data(contentsOf: $0) }
            .mapError(FileClientError.reading)
            .flatMap { [self] in decode(type: type, from: $0) }
            .eraseToAnyPublisher()
    }

    func objectMonitor<T: Codable>(of type: T.Type, from filename: String) -> AnyPublisher<T, FileClientError> {
        monitor.folderDidChange
            .setFailureType(to: FileClientError.self)
            .flatMap { [self] in object(of: type, from: filename) }
            .eraseToAnyPublisher()
    }
}

public extension FileClient {
    func files() -> AnyPublisher<[URL], FileClientError> {
        return Future { [fileManager, location] promise in
            do {
                let urls = try fileManager.contentsOfDirectory(
                    at: location.url,
                    includingPropertiesForKeys: nil,
                    options: []
                )
                .filter { url in
                    url.pathExtension == "json"
                }

                if case .icloud(identifier: _) = location {
                    try? urls.forEach(fileManager.startDownloadingUbiquitousItem(at:))
                }
                promise(.success(urls))
            } catch {
                promise(.failure(.reading(error)))
            }
        }.eraseToAnyPublisher()
    }

    func objects<T: Codable>(from files: [URL]) -> AnyPublisher<[T], FileClientError> {
        Publishers.Sequence<[URL], Error>(sequence: files)
            .tryMap { try Data(contentsOf: $0) }
            .mapError(FileClientError.reading)
            .compactMap { [decoder] in try? decoder.decode(T.self, from: $0) }
            .collect()
            .eraseToAnyPublisher()
    }

    func objects<T: Codable>(of _: T.Type) -> AnyPublisher<[T], FileClientError> {
        files()
            .flatMap(objects(from:))
            .eraseToAnyPublisher()
    }

    func objectMonitor<T: Codable>(of type: T.Type) -> AnyPublisher<[T], FileClientError> {
        monitor.folderDidChange
            .setFailureType(to: FileClientError.self)
            .flatMap { [self] _ in objects(of: type) }
            .eraseToAnyPublisher()
    }
}

// MARK: - Deleting

public extension FileClient {
    func delete(filename: String) -> AnyPublisher<Void, FileClientError> {
        Future { [fileManager, location] promise in
            do {
                try fileManager.removeItem(at: location.url(for: filename))
                promise(.success(()))
            } catch {
                promise(.failure(.deleting(error)))
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: - Helpers

private extension FileClient {
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

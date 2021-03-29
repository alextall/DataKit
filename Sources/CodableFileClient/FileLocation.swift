import Foundation

public enum FileLocation {
    case applicationSupport
    case documents
    case cache
    case appGroup(identifier: String)
    // TODO for testability
    //    case memory
}

extension FileLocation {
    var url: URL {
        let possibleURL: URL?

        switch self {
        case .applicationSupport:
            possibleURL = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first
        case .appGroup(let identifier):
            return FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: identifier
            )!
        case .documents:
            return FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )
            .first!
        case .cache:
            return FileManager.default.urls(
                for: .cachesDirectory,
                in: .userDomainMask
            )
            .first!
        }

        guard let url = possibleURL else {
            fatalError("URL for \(self) does not exist")
        }

        return url
    }

    var path: String {
        url.absoluteString
    }

    func url(for filename: String) -> URL {
        url.appendingPathComponent(filename + ".json")
    }
}

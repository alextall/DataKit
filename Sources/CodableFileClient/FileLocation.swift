import Foundation

public enum FileLocation {
    case appGroup(identifier: String)
    case applicationSupport
    case documents
    case cache
    case custom(url: URL)
}

extension FileLocation {
    var url: URL {
        let possibleURL: URL?

        switch self {
        case let .appGroup(identifier):
            possibleURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: identifier
            )?.appendingPathComponent("Documents")
        case .applicationSupport:
            possibleURL = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first
        case .cache:
            possibleURL = FileManager.default.urls(
                for: .cachesDirectory,
                in: .userDomainMask
            )
            .first
        case let .custom(capturedURL):
            possibleURL = capturedURL
        case .documents:
            possibleURL = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )
            .first
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

import Foundation

public enum FileLocation {
    case local
    case appGroup(identifier: String)
    // TODO for testability
    //    case memory
}

extension FileLocation {
    var url: URL {
        switch self {
        case .local:
            return FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )
            .first!
        case .appGroup(let identifier):
            return FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: identifier
            )!
        }
    }

    var path: String {
        url.absoluteString
    }

    func url(for filename: String) -> URL {
        url.appendingPathComponent(filename + ".json")
    }
}

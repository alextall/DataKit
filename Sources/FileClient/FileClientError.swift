import Foundation

public enum FileClientError: Error {
    case encoding(Error)
    case decoding(Error)
    case writing(Error)
    case reading(Error)
    case deleting(Error)
}

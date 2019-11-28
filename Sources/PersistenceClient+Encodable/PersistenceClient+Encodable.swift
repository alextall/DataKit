
import CoreData
import Foundation
import PersistenceClient


public extension PersistenceClient {
    /// Encodes the object(s) in the given `ScratchPad` to JSON.
    /// - Parameter scratchPad: A `ScratchPad` with objects to encode
    /// - Parameter encoder: A `JSONEncoder` to use for encoding
    /// - Throws:  Will throw a `PersistenceError` if there are no objects to encode.
    func encodeToJSON<T: NSManagedObject>(scratchPad: ScratchPad<T>,
                                          with encoder: JSONEncoder = JSONEncoder()) throws 
        -> Data where T: Encodable {
        switch scratchPad {
        case .empty: throw PersistenceError.encoding
        case .list(value: let list, context: _): return try encoder.encode(list)
        case .object(value: let object, context: _): return try encoder.encode(object)
        }
    }
}

public extension PersistenceClient {
    /// Encodes the object(s) in the given `ScratchPad` to a Plist.
    /// - Parameter scratchPad: A `ScratchPad` with objects to encode
    /// - Parameter encoder: A `PropertyListEncoder` to use for encoding
    /// - Throws:  Will throw a `PersistenceError` if there are no objects to encode.
    func encodeToPlist<T: NSManagedObject>(scratchPad: ScratchPad<T>,
                                           with encoder: PropertyListEncoder = PropertyListEncoder()) throws 
        -> Data where T: Encodable {
        switch scratchPad {
        case .empty: throw PersistenceError.encoding
        case .list(value: let list, context: _): return try encoder.encode(list)
        case .object(value: let object, context: _): return try encoder.encode(object)
        }
    }
}

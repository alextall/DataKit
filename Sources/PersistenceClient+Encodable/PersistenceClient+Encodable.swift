import CoreData
import Foundation
import PersistenceClient

public extension PersistenceClient {
    /// Encodes an instance of the indicated type.
    func encodeToJSON<T: NSManagedObject>(scratchPad: ScratchPad<T>) throws -> Data where T: Encodable {
        let encoder = JSONEncoder()

        switch scratchPad {
        case .empty: throw PersistenceError.encoding
        case .list(value: let list, context: _): return try encoder.encode(list)
        case .object(value: let object, context: _): return try encoder.encode(object)
        }
    }
}

public extension PersistenceClient {
    /// Encodes an instance of the indicated type.
    func encodeToPlist<T: NSManagedObject>(scratchPad: ScratchPad<T>) throws -> Data where T: Encodable {
        let encoder = PropertyListEncoder()

        switch scratchPad {
        case .empty: throw PersistenceError.encoding
        case .list(value: let list, context: _): return try encoder.encode(list)
        case .object(value: let object, context: _): return try encoder.encode(object)
        }
    }
}

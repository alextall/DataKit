import Foundation
import CoreData
import PersistenceClient

public extension PersistenceClient {
    func encode<T: NSManagedObject>(scratchPad: ScratchPad<T>) throws -> Data where T: Encodable {
        let encoder = JSONEncoder()

        switch scratchPad {
        case .empty(_): throw PersistenceError.noObjectsMatchingPredicate
        case .list(value: let list, context: _): return try encoder.encode(list)
        case .object(value: let object, context: _): return try encoder.encode(object)
        }
    }
}

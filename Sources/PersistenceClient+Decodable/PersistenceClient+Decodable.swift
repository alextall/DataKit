import CoreData
import Foundation
import PersistenceClient

public extension PersistenceClient {
    /// Decodes an instance of the indicated type.
    func decodeJSON<T: NSManagedObject>(_ data: Data,
                                        with decoder: JSONDecoder = JSONDecoder(),
                                        to _: T.Type,
                                        in context: NSManagedObjectContext? = nil) throws
        -> ScratchPad<T> where T: Decodable {
        let context = context ?? newBackgroundContext()
        decoder.userInfo[CodingUserInfoKey.managedObjectContext!] = context
        
        let result = try decoder.decode(T.self, from: data)
        
        return .object(value: result, context: context)
    }
    
    /// Decodes an instance of the indicated type.
    func decodeJSON<T: NSManagedObject>(_ data: Data,
                                        with decoder: JSONDecoder = JSONDecoder(),
                                        to _: [T].Type,
                                        in context: NSManagedObjectContext? = nil) throws
        -> ScratchPad<T> where T: Decodable {
        let context = context ?? newBackgroundContext()
        decoder.userInfo[CodingUserInfoKey.managedObjectContext!] = context
        
        do {
            let result = try decoder.decode([T].self, from: data)
            return .list(value: result, context: context)
        } catch {
            throw PersistenceError.decoding
        }
    }
}

public extension PersistenceClient {
    /// Decodes an instance of the indicated type.
    func decodePlist<T: NSManagedObject>(_ data: Data,
                                         with decoder: PropertyListDecoder = PropertyListDecoder(),
                                         to _: T.Type,
                                         in context: NSManagedObjectContext? = nil) throws
        -> ScratchPad<T> where T: Decodable {
        let context = context ?? newBackgroundContext()
        decoder.userInfo[CodingUserInfoKey.managedObjectContext!] = context
        
        do {
            let result = try decoder.decode([T].self, from: data)
            return .list(value: result, context: context)
        } catch {
            throw PersistenceError.decoding
        }
    }
    
    /// Decodes an instance of the indicated type.
    func decodePlist<T: NSManagedObject>(_ data: Data,
                                         with decoder: PropertyListDecoder = PropertyListDecoder(),
                                         to _: [T].Type,
                                         in context: NSManagedObjectContext? = nil) throws
        -> ScratchPad<T> where T: Decodable {
        let context = context ?? newBackgroundContext()
        decoder.userInfo[CodingUserInfoKey.managedObjectContext!] = context
        
        do {
            let result = try decoder.decode([T].self, from: data)
            return .list(value: result, context: context)
        } catch {
            throw PersistenceError.decoding
        }
    }
}

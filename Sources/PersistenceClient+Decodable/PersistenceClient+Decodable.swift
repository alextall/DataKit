import Foundation
import CoreData
import PersistenceClient

public extension PersistenceClient {
    func decode<T: NSManagedObject>(_: T.Type, from data: Data) throws -> ScratchPad<T> where T:
    Decodable {
        let decoder = JSONDecoder()
        let context = newBackgroundContext()
        decoder.userInfo[CodingUserInfoKey.managedObjectContext!] = context

        let result = try decoder.decode(T.self, from: data)

        return .object(value: result, context: context)
    }

    func decode<T: NSManagedObject>(_: [T].Type, from data: Data) throws -> ScratchPad<T> where T:
    Decodable {
        let decoder = JSONDecoder()
        let context = newBackgroundContext()
        decoder.userInfo[CodingUserInfoKey.managedObjectContext!] = context

        let result = try decoder.decode([T].self, from: data)

        return .list(value: result, context: context)
    }
}

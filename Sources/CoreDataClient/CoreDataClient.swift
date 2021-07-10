import Combine
import CoreData
import Foundation
import os

public class CoreDataClient {
    private let container: NSPersistentContainer
    private let contextDidSave: PassthroughSubject<(), Never>

    public init(container: NSPersistentContainer = defaultContainer) {
        os_log("Loading persistent stores...")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error loading persistent stores: \(error.localizedDescription)")
            }
            os_log("Successfully loaded persistent stores.")
        }
        self.container = container
        container.viewContext.automaticallyMergesChangesFromParent = true
        contextDidSave = .init()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotification),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }

    @objc private func handleNotification() {
        contextDidSave.send()
    }

    /// URLs for the persistent stores.
    /// Useful for debugging purposes
    public var storeURLs: [URL] {
        return container.persistentStoreDescriptions.compactMap(\.url)
    }
}

public extension CoreDataClient {
    private class var defaultManagedObjectModel: NSManagedObjectModel {
        for url in Bundle.main.urls(forResourcesWithExtension: "momd", subdirectory: nil) ?? [] {
            if let model = NSManagedObjectModel(contentsOf: url) {
                return model
            }
        }
        fatalError("Failed to find managed object model file.")
    }

    /// A default `NSPersistentContainer`
    /// - Uses the `Bundle.main.bundleIdentifier` or "model" as a default name.
    /// - Searches `Bundle.main` for an `NSManagedObjectModel`
    class var defaultContainer: NSPersistentContainer {
        return NSPersistentContainer(name: Bundle.main.bundleIdentifier ?? "model",
                                     managedObjectModel: defaultManagedObjectModel)
    }

    /// An `NSPersistentContainer` with a store of type `NSInMemoryStoreType`
    /// - Uses the `defaultContainer`
    class var inMemoryContainer: NSPersistentContainer {
        let container = defaultContainer
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        return container
    }

    /// An `NSPersistentCloudKitContainer`
    /// - Uses the `Bundle.main.bundleIdentifier` or "model" as a default name.
    /// - Searches `Bundle.main` for an `NSManagedObjectModel`
    class var cloudKitContainer: NSPersistentContainer {
        return NSPersistentCloudKitContainer(name: Bundle.main.bundleIdentifier ?? "model",
                                             managedObjectModel: defaultManagedObjectModel)
    }
}

public enum PersistenceError: Error {
    case noObjectsMatchingPredicate
    case contextFetch(NSError)
    case contextSave(NSError)
    case encoding
    case decoding
}

// MARK: - Contexts

public extension CoreDataClient {
    /// The managed object context associated with the main queue. (read-only)
    ///
    /// This property contains a reference to the `NSManagedObjectContext` that is created and owned by the persistent container which is associated with the main queue of the application. This context is created automatically as part of the initialization of the persistent container.
    ///
    /// This context is associated directly with the `NSPersistentStoreCoordinator` and is non-generational by default.
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    /// Creates a private managed object context.
    ///
    /// Invoking this method causes the persistent container to create and return a new `NSManagedObjectContext` with the `concurrencyType` set to `NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType`. This new context will be associated with the `NSPersistentStoreCoordinator` directly and is set to consume `NSManagedObjectContextDidSave` broadcasts automatically.
    func newBackgroundContext() -> NSManagedObjectContext {
        return container.newBackgroundContext()
    }
}

// MARK: - Saving

public extension CoreDataClient {
    /// Saves the underlying `NSManagedObjectContext` in a `ScratchPad`
    /// - Parameter scratchPad: `ScratchPad` with changes to save.
    func save<T>(scratchPad: ScratchPad<T>) async throws {
        try await save(context: scratchPad.context)
    }

    private func save(context: NSManagedObjectContext) async throws {
        async {
            if context.hasChanges {
                try context.save()
            }
        }
    }
}

// MARK: - Fetching

public extension CoreDataClient {
    /// Returns a `ScratchPad` of containing an array of objects that meet the criteria specified by a given fetch request.
    /// - Parameters:
    ///   - fetchRequest: `NSFetchRequest` describing the objects to retrieve
    ///   - context: `NSManagedObjectContext` to use. Defaults to the `viewContext` if nil.
    func objects<T: NSFetchRequestResult>(for fetchRequest: NSFetchRequest<T>,
                                          in context: NSManagedObjectContext? = nil) async throws -> ScratchPad<T> {
        let context = context ?? viewContext
        let result = try context.fetch(fetchRequest)
        return .list(value: result, context: context)
    }

//    func objectsMonitor<T: NSFetchRequestResult>(for fetchRequest: NSFetchRequest<T>,
//                                                in context: NSManagedObjectContext? = nil) -> AnyPublisher<ScratchPad<T>, PersistenceError> {
//        contextDidSave
//            .map { (fetchRequest, context) }
//            .flatMap(objects(for:in:))
//            .eraseToAnyPublisher()
//    }

    /// Returns a `ScratchPad` of containing a single object that meet the criteria specified by a given fetch request.
    /// - Parameters:
    ///   - fetchRequest: `NSFetchRequest` describing the objects to retrieve
    ///   - context: `NSManagedObjectContext` to use. Defaults to the `viewContext` if nil.
    func object<T: NSFetchRequestResult>(for fetchRequest: NSFetchRequest<T>,
                                         in context: NSManagedObjectContext? = nil)
        -> Future<ScratchPad<T>, PersistenceError> {
        let context = context ?? viewContext
        return Future { promise in
            do {
                let result = try context.fetch(fetchRequest)
                if let object = result.first {
                    return promise(.success(.object(value: object, context: context)))
                } else {
                    return promise(.failure(.noObjectsMatchingPredicate))
                }
            } catch let error as NSError {
                return promise(.failure(.contextFetch(error)))
            }
        }
    }

    func objectMonitor<T: NSFetchRequestResult>(for fetchRequest: NSFetchRequest<T>,
                                                 in context: NSManagedObjectContext? = nil) -> AnyPublisher<ScratchPad<T>, PersistenceError> {
        contextDidSave
            .map { (fetchRequest, context) }
            .flatMap(object(for:in:))
            .eraseToAnyPublisher()
    }
}

// MARK: - Object Reification

public extension CoreDataClient {
    /// Fetches the requested object from the specified context.
    /// - Parameters:
    ///   - obj: The object to fetch.
    ///   - context: `NSManagedObjectContext` to use. Defaults to the `viewContext` if nil.
    func object<T: NSManagedObject>(_ obj: T,
                                    in context: NSManagedObjectContext? = nil) -> ScratchPad<T> {
        let context = context ?? viewContext
        if obj.managedObjectContext == context {
            return .object(value: obj, context: context)
        }
        return object(for: T.self, with: obj.objectID, in: context)
    }

    private func object<T: NSManagedObject>(for _: T.Type,
                                            with objectID: NSManagedObjectID,
                                            in context: NSManagedObjectContext) -> ScratchPad<T> {
        guard let existing = try? context.existingObject(with: objectID) as? T else {
            return .empty(context)
        }
        return .object(value: existing, context: context)
    }
}

// MARK: - Deletion

public extension CoreDataClient {
    /// Deletes all objects of the given type from the specified context.
    /// - Parameters:
    ///   - type: The type of a set of objects to delete.
    ///   - context: `NSManagedObjectContext` to use. Defaults to the `viewContext` if nil.
    @discardableResult
    func deleteObjects<T: NSManagedObject>(ofType _: T.Type,
                                           in context: NSManagedObjectContext? = nil)
        -> Future<ScratchPad<T>, PersistenceError> {
        let context = context ?? viewContext
        return Future { promise in
            do {
                let request = T.fetchRequest()
                guard let all = try context.fetch(request) as? [T] else {
                    return promise(.failure(.noObjectsMatchingPredicate))
                }
                all.forEach(context.delete)
                return promise(.success(.empty(context)))
            } catch let error as NSError {
                return promise(.failure(.contextFetch(error)))
            }
        }
    }

    /// Deletes all objects in the given scratchpad.
    /// - Parameters:
    ///   - scratch: `ScratchPad` to use
    @discardableResult
    func deleteObjects<T: NSManagedObject>(in scratch: ScratchPad<T>)
        -> Future<ScratchPad<T>, Never> {
        return Future { promise in
            scratch.array.forEach(scratch.context.delete)
            try? scratch.context.save()
            return promise(.success(.empty(scratch.context)))
        }
    }
}

// MARK: - Object Instantiation

public extension CoreDataClient {
    /// Instantiates a new object of the given type using the specified context.
    /// - Parameters:
    ///   - type: The type of object to instantiate.
    ///   - context: `NSManagedObjectContext` to use. Defaults to the `viewContext` if nil.
    /// - Returns: A `ScratchPad` with an object of the type passed in.
    func new<T: NSManagedObject>(_: T.Type,
                                 in context: NSManagedObjectContext? = nil) -> ScratchPad<T> {
        let context = context ?? viewContext
        return .object(value: T(context: context), context: context)
    }
}

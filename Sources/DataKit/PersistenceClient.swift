import Combine
import CoreData
import Foundation
import os

public class PersistenceClient {
    private let container: NSPersistentContainer
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
    public class var defaultContainer: NSPersistentContainer {
        return NSPersistentContainer(name: Bundle.main.bundleIdentifier ?? "model",
                                     managedObjectModel: defaultManagedObjectModel)
    }

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
    }

    /// URLs for the persistent stores.
    /// Useful for debugging purposes
    public var storeURL: [URL] {
        return container.persistentStoreDescriptions.compactMap { $0.url }
    }
}

public extension PersistenceClient {
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

public extension PersistenceClient {
    enum PersistenceError: Error {
        case noObjectsMatchingPredicate
        case contextFetch(underlyingError: NSError)
        case contextSave(underlyingError: NSError)
    }
}

// MARK: - Contexts

public extension PersistenceClient {
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

public extension PersistenceClient {
    @discardableResult
    func save<T>(scratchPad: ScratchPad<T>) -> Future<ScratchPad<T>, PersistenceError> {
        return Future { promise in
            _ = self.save(context: scratchPad.context)
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        promise(.failure(error))
                    }
                }) { _ in
                    promise(.success(scratchPad))
                }
        }
    }

    private func save(context: NSManagedObjectContext) -> Future<Void, PersistenceError> {
        return Future<Void, PersistenceError> { promise in
            do {
                if context.hasChanges {
                    try context.save()
                }
                promise(.success(()))
            } catch let error as NSError {
                promise(.failure(.contextSave(underlyingError: error)))
            }
        }
    }
}

// MARK: - Fetching

public extension PersistenceClient {
    func objects<T: NSFetchRequestResult>(for fetchRequest: NSFetchRequest<T>,
                                          in context: NSManagedObjectContext? = nil)
        -> Future<ScratchPad<T>, PersistenceError> {
        let context = context ?? viewContext
        return Future { promise in
            do {
                let result = try context.fetch(fetchRequest)
                return promise(.success(.list(value: result, context: context)))
            } catch let error as NSError {
                return promise(.failure(.contextFetch(underlyingError: error)))
            }
        }
    }

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
                return promise(.failure(.contextFetch(underlyingError: error)))
            }
        }
    }
}

// MARK: - Object Reification

public extension PersistenceClient {
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

// MARK: - Deleting

public extension PersistenceClient {
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
                return promise(.failure(.contextFetch(underlyingError: error)))
            }
        }
    }

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

public extension PersistenceClient {
    func new<T: NSManagedObject>(_: T.Type,
                                 in context: NSManagedObjectContext? = nil) -> ScratchPad<T> {
        let context = context ?? viewContext
        return .object(value: T(context: context), context: context)
    }
}

// public extension PersistenceClient {
//    func newFetchedRestultsController<T: NSManagedObject>(of type: T.Type,
//                                                          in context: NSManagedObjectContext? = nil) -> NSFetchedResultsController<T> {
//        let context = context ?? viewContext
//        return NSFetchedResultsController(fetchRequest: T.fetchRequest(),
//                                          managedObjectContext: context,
//                                          sectionNameKeyPath: nil,
//                                          cacheName: nil)
//    }
// }

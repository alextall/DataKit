import Foundation
import CoreData
@testable import CoreDataClient

func inMemoryStack() -> CoreDataClient {
    var managedObjectModel: NSManagedObjectModel {
        let momURL = Bundle.module.url(forResource: nil, withExtension: "mom")!
        let mom = NSManagedObjectModel(contentsOf: momURL)!
        print(mom.entities.map(\.managedObjectClassName))
        return mom
    }

    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "CoreDataClientTests",
                                     managedObjectModel: managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        return container
    }

    return CoreDataClient(container: container)
}

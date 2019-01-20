import CoreData

public extension NSPersistentStoreCoordinator {
    func destroyPersistentStore(description: NSPersistentStoreDescription) throws {
        try description.url.map {
            try destroyPersistentStore(at: $0, ofType: description.type)
        }
    }
}

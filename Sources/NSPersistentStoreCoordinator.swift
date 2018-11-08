import CoreData

public extension NSPersistentStoreCoordinator {
    func destroyStore(description: NSPersistentStoreDescription) throws {
        if let url = description.url {
            try destroyPersistentStore(at: url, ofType: description.type)
        }
    }
}
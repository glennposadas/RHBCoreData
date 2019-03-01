import CoreData

extension NSPersistentStoreCoordinator {
    func removeStores() throws {
        try persistentStores.forEach {
            try remove($0)
        }
    }
}

import CoreData

public extension NSPersistentStoreCoordinator {
    func destroyPersistentStores(descriptions: [NSPersistentStoreDescription]) throws {
        try descriptions.forEach {
            guard let url = $0.url else {
                return
            }
            try destroyPersistentStore(at: url, ofType: $0.type)
        }
    }

    func removeStores() throws {
        try persistentStores.forEach {
            try remove($0)
        }
    }
}

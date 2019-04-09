import CoreData

extension NSPersistentStoreCoordinator {
    func destroyPersistentStores(_ descriptions: [NSPersistentStoreDescription]) throws {
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

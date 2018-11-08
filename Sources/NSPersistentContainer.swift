import CoreData

public extension NSPersistentContainer {
    convenience init(fileUrl: URL, model: NSManagedObjectModel) {
        let name = fileUrl.deletingPathExtension().lastPathComponent
        self.init(name: name, managedObjectModel: model)
        self.persistentStoreDescriptions.first?.url = fileUrl
    }
    
    func destroyStores() throws {
        try persistentStoreDescriptions.forEach { storeDescription in
            try persistentStoreCoordinator.destroyStore(description: storeDescription)
        }
    }

    func loadStoresSync() -> [(NSPersistentStoreDescription, Error)] {
        persistentStoreDescriptions.forEach {
            $0.shouldAddStoreAsynchronously = false
        }
        var errors: [(NSPersistentStoreDescription, Error)] = []
        loadPersistentStores { storeDescription, error in
            if let error = error {
                errors.append((storeDescription, error))
            }
        }
        return errors
    }

    func loadStoresAsync(completionQueue: DispatchQueue = .main, _ block: @escaping ([(NSPersistentStoreDescription, Error)]) -> Void) {
        let group = DispatchGroup()
        persistentStoreDescriptions.forEach {
            $0.shouldAddStoreAsynchronously = true
            group.enter()
        }
        var errors: [(NSPersistentStoreDescription, Error)] = []
        loadPersistentStores { storeDescription, error in
            if let error = error {
                errors.append((storeDescription, error))
            }
            group.leave()
        }
        group.notify(queue: completionQueue) {
            block(errors)
        }
    }
}

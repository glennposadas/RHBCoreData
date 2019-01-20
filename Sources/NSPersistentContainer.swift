import CoreData

public extension NSPersistentContainer {
    convenience init(storeUrl: URL, model: NSManagedObjectModel) {
        self.init(name: storeUrl.deletingPathExtension().lastPathComponent, managedObjectModel: model)
        persistentStoreDescriptions.first?.url = storeUrl
    }

    func destroyPersistentStores() throws {
        try persistentStoreDescriptions.forEach { try persistentStoreCoordinator.destroyPersistentStore(description: $0) }
    }

    @discardableResult
    func loadIfNotRecreate() throws -> Bool {
        try createPersistentStoreDirectories()
        if loadPersistentStoresSync().isEmpty {
            return true
        }
        try destroyPersistentStores()
        if let error = loadPersistentStoresSync().first?.1 {
            throw error
        }
        return false
    }

    func createPersistentStoreDirectories() throws {
        try persistentStoreDescriptions
            .compactMap { $0.url?.deletingLastPathComponent() }
            .forEach { try FileManager().createDirectory(at: $0, withIntermediateDirectories: true) }
    }

    func loadPersistentStoresSync() -> [(NSPersistentStoreDescription, Error)] {
        persistentStoreDescriptions.forEach {
            $0.shouldAddStoreAsynchronously = false
        }
        var errors: [(NSPersistentStoreDescription, Error)] = []
        loadPersistentStores { storeDescription, error in
            error.map {
                errors.append((storeDescription, $0))
            }
        }
        return errors
    }

    func loadPersistentStoresAsync(completionQueue: DispatchQueue = .main, _ block: @escaping ([(NSPersistentStoreDescription, Error)]) -> Void) {
        let group = DispatchGroup()
        persistentStoreDescriptions.forEach {
            $0.shouldAddStoreAsynchronously = true
            group.enter()
        }
        var errors: [(NSPersistentStoreDescription, Error)] = []
        loadPersistentStores { storeDescription, error in
            error.map {
                errors.append((storeDescription, $0))
            }
            group.leave()
        }
        group.notify(queue: completionQueue) {
            block(errors)
        }
    }
}

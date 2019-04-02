import CoreData
import RHBFoundation

public extension NSPersistentContainer {
    convenience init(memoryModel model: NSManagedObjectModel, name: String = #function) {
        self.init(name: name, managedObjectModel: model)
        persistentStoreDescriptions.first?.type = NSInMemoryStoreType
    }

    convenience init(storeUrl: URL, model: NSManagedObjectModel) {
        self.init(name: storeUrl.deletingPathExtension().lastPathComponent, managedObjectModel: model)
        persistentStoreDescriptions.first?.url = storeUrl
    }

    func destroyPersistentStores() throws {
        try persistentStoreDescriptions.forEach { try persistentStoreCoordinator.destroyPersistentStore(description: $0) }
    }

    func loadIfNotRecreate() throws {
        try createPersistentStoreDirectories()
        if loadPersistentStoresSync().isEmpty {
            return
        }
        try destroyPersistentStores()
        if let error = loadPersistentStoresSync().first {
            throw error
        }
    }

    func createPersistentStoreDirectories() throws {
        try persistentStoreDescriptions
            .compactMap { $0.url?.deletingLastPathComponent() }
            .forEach { try FileManager().createDirectory(at: $0, withIntermediateDirectories: true) }
    }

    func loadPersistentStoresSync() -> [ErrorWithValue<NSPersistentStoreDescription>] {
        persistentStoreDescriptions.forEach {
            $0.shouldAddStoreAsynchronously = false
        }
        var errors: [ErrorWithValue<NSPersistentStoreDescription>] = []
        loadPersistentStores { storeDescription, error in
            error.map {
                errors.append(.valueAnderror(storeDescription, $0))
            }
        }
        return errors
    }

    func loadPersistentStoresAsync(completionQueue: DispatchQueue = .main, _ block: @escaping (Result<NSPersistentContainer, ErrorWithValue<[ErrorWithValue<NSPersistentStoreDescription>]>>) -> Void) {
        let group = DispatchGroup()
        persistentStoreDescriptions.forEach {
            $0.shouldAddStoreAsynchronously = true
            group.enter()
        }
        var errors: [ErrorWithValue<NSPersistentStoreDescription>] = []
        loadPersistentStores { storeDescription, error in
            error.map {
                errors.append(.valueAnderror(storeDescription, $0))
            }
            group.leave()
        }
        group.notify(queue: completionQueue) {
            if errors.isEmpty {
                block(.success(self))
            } else {
                block(.failure(.value(errors)))
            }
        }
    }
}

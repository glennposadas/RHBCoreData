import CoreData
import RHBFoundation

public extension NSPersistentContainer {
    convenience init(inMemory model: NSManagedObjectModel) {
        self.init(name: NSInMemoryStoreType, managedObjectModel: model)
        persistentStoreDescriptions.first?.type = NSInMemoryStoreType
    }

    convenience init(storeUrl: URL, model: NSManagedObjectModel) {
        self.init(name: storeUrl.deletingPathExtension().lastPathComponent, managedObjectModel: model)
        persistentStoreDescriptions.first?.url = storeUrl
    }

    func destroyPersistentStores() throws {
        try persistentStoreDescriptions.forEach { try persistentStoreCoordinator.destroyPersistentStore(description: $0) }
    }

    func createPersistentStoreDirectories() throws {
        try persistentStoreDescriptions
            .compactMap { $0.url?.deletingLastPathComponent() }
            .forEach { try FileManager().createDirectory(at: $0, withIntermediateDirectories: true) }
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
        group.notify(queue: completionQueue) { [weak self] in
            self.map {
                if errors.isEmpty {
                    block(.success($0))
                } else {
                    block(.failure(.value(errors)))
                }
            }
        }
    }
}

import CoreData

public extension NSPersistentContainer {
    func loadPersistentStoresAsync(_ block: @escaping ([(NSPersistentStoreDescription, Error)]) -> Void) {
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
        group.notify(queue: .main) {
            block(errors)
        }
    }
}

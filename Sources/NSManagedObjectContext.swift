import CoreData

public extension NSManagedObjectContext {
    func performTaskAndWait(_ block: @escaping (NSManagedObjectContext) -> Void) {
        performAndWait {
            block(self)
        }
    }
    func performTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        perform { [unowned self] in
            block(self)
        }
    }
    func save(_ block: (Error)->Void) {
        guard hasChanges else {
            return
        }
        do {
            try save()
        } catch {
            block(error)
        }
    }
    func reloadObject<T: NSManagedObject>(other: T) -> T? {
        let baseObject = try? existingObject(with: other.objectID)
        return baseObject as? T
    }
}


import CoreData

public extension NSManagedObjectContext {
    func fetchMore<T: NSManagedObject>(_ request: NSFetchRequest<T>, _ block: ((Error) -> Void)? = nil) -> [T]? {
        do {
            return try fetch(request)
        } catch {
            block?(error)
        }
        return nil
    }

    func fetchOne<T: NSManagedObject>(_ request: NSFetchRequest<T>, _ block: ((Error) -> Void)? = nil) -> T? {
        return fetchMore(request, block)?.first
    }

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

    func performResult<T>(_ block: @escaping (NSManagedObjectContext) -> T) -> T {
        var t: T!
        performAndWait {
            t = block(self)
        }
        return t
    }

    @discardableResult
    func saveChanges(_ block: ((Error)->Void)? = nil) -> Bool {
        guard hasChanges else {
            return true
        }
        do {
            try save()
            return true
        } catch {
            block?(error)
            return false
        }
    }

    func reloadObject<T: NSManagedObject>(other: T) -> T? {
        let baseObject = try? existingObject(with: other.objectID)
        return baseObject as? T
    }
}

public extension Array where Element: NSManagedObject {
    func reloadedObjects(in context: NSManagedObjectContext) -> [Element] {
        return compactMap { context.reloadObject(other: $0) }
    }
}


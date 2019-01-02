import CoreData

public extension NSManagedObjectContext {
    func fetchArray<T: NSManagedObject>(_ request: NSFetchRequest<T>, _ block: ((Error) -> Void)? = nil) -> [T]? {
        do {
            return try fetch(request)
        } catch {
            block?(error)
            return nil
        }
    }

    func fetchObject<T: NSManagedObject>(_ request: NSFetchRequest<T>, _ block: ((Error) -> Void)? = nil) -> T? {
        return fetchArray(request, block)?.first
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
    func saveChanges(_ block: ((Error) -> Void)? = nil) -> Bool {
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

    func reloadObject<T: NSManagedObject>(other: T, _ block: ((Error) -> Void)? = nil) -> T? {
        var object: T?
        do {
            object = try existingObject(with: other.objectID) as? T
        } catch {
            block?(error)
        }
        return object
    }

    func reloadArray<T: NSManagedObject>(array: [T], _ block: ((Error) -> Void)? = nil) -> [T] {
        return array.compactMap { reloadObject(other: $0, block) }
    }
}

import CoreData

public extension NSManagedObjectContext {
    func fetchArray<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>, _ failure: (Error) -> Void = CoreDataErrorHandler.shared) -> [T]? {
        do {
            return try fetch(request)
        } catch {
            failure(error)
            return nil
        }
    }

    func fetchObject<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>, _ failure: (Error) -> Void = CoreDataErrorHandler.shared) -> T? {
        return fetchArray(request, failure)?.first
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
    func save(failure: (Error) -> Void = CoreDataErrorHandler.shared) -> Bool {
        do {
            try save()
            return true
        } catch {
            failure(error)
            return false
        }
    }

    @discardableResult
    func saveChanges(failure: (Error) -> Void = CoreDataErrorHandler.shared) -> Bool {
        guard hasChanges else {
            return true
        }
        return save(failure: failure)
    }

    func reloadObject<T: NSManagedObject>(other: T, _ failure: (Error) -> Void = CoreDataErrorHandler.shared) -> T? {
        var object: T?
        do {
            object = try existingObject(with: other.objectID) as? T
        } catch {
            failure(error)
        }
        return object
    }

    func reloadArray<T: NSManagedObject>(array: [T], _ failure: (Error) -> Void = CoreDataErrorHandler.shared) -> [T] {
        return array.compactMap { reloadObject(other: $0, failure) }
    }

    func fetchedResultsController<T: NSFetchRequestResult>(request: NSFetchRequest<T>, sectionNameKeyPath: String? = nil, cacheName: String? = nil) -> NSFetchedResultsController<T> {
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: self, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
    }
}

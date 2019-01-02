import CoreData

public extension NSManagedObjectContext {
    func fetchArray<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>, _ failure: (Error) -> Void = CoreDataErrorHandler.shared) -> [T] {
        do {
            return try fetch(request)
        } catch {
            failure(error)
            return []
        }
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

    func performTaskAndWaitResult<T>(_ block: @escaping (NSManagedObjectContext) -> T) -> T {
        var t: T!
        performAndWait {
            t = block(self)
        }
        return t
    }

    @discardableResult
    func saveChanges(failure: (Error) -> Void = CoreDataErrorHandler.shared) -> Bool {
        guard hasChanges else {
            return true
        }
        do {
            try save()
            return true
        } catch {
            failure(error)
            return false
        }
    }

    func reloadObject<T: NSManagedObject>(_ other: T, _ failure: (Error) -> Void = CoreDataErrorHandler.shared) -> T? {
        var object: T?
        do {
            object = try existingObject(with: other.objectID) as? T
        } catch {
            failure(error)
        }
        return object
    }

    func reloadArray<S: Sequence>(_ sequence: S, _ failure: (Error) -> Void = CoreDataErrorHandler.shared) -> [S.Element] where S.Element: NSManagedObject {
        let request = genericFetchRequest(S.Element.self)
        request.predicate = NSPredicate(format: "self IN %@", argumentArray: [sequence.map { $0.objectID }])
        return fetchArray(request, failure)
    }

    func fetchedResultsController<T: NSFetchRequestResult>(request: NSFetchRequest<T>, sectionNameKeyPath: String? = nil, cacheName: String? = nil) -> NSFetchedResultsController<T> {
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: self, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
    }
}

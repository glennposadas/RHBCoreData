import CoreData

public extension NSManagedObjectContext {
    func performTaskAndWait(_ block: @escaping (NSManagedObjectContext) -> Void) {
        performAndWait { [unowned self] in
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
        performTaskAndWait { t = block($0) }
        return t
    }

    func saveChanges() throws {
        guard hasChanges else {
            return
        }
        try save()
    }

    func refetch<S: Sequence>(_ sequence: S) throws -> [S.Element] where S.Element: NSManagedObject {
        let request = FetchRequestBuilder<S.Element>()
            .predicate(NSPredicate(format: "self IN %@", argumentArray: [sequence]))
            .request
        return try fetch(request)
    }

    func createFetchedResultsController<T: NSFetchRequestResult>(request: NSFetchRequest<T>, sectionNameKeyPath: String? = nil, cacheName: String? = nil) -> NSFetchedResultsController<T> {
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: self, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
    }

    func createObject<T: NSManagedObject>() -> T {
        return T(context: self)
    }
}

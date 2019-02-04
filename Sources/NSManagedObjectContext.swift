import CoreData

public extension NSManagedObjectContext {
    func performTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        perform { [unowned self] in
            block(self)
        }
    }

    func saveChanges() throws {
        guard hasChanges else {
            return
        }
        try save()
    }

    func refetch<S: Sequence>(_ sequence: S) throws -> [S.Element] where S.Element: NSManagedObject {
        let request = FetchRequestBuilder<S.Element>().request {
            $0.predicate = NSPredicate(format: "self IN %@", argumentArray: [sequence])
        }
        return try fetch(request)
    }

    func createFetchedResultsController<T: NSFetchRequestResult>(request: NSFetchRequest<T>, sectionNameKeyPath: String? = nil, cacheName: String? = nil) -> NSFetchedResultsController<T> {
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: self, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
    }

    func createObject<T: NSManagedObject>(_ initObject: (T) -> Void = { _ in }) -> T {
        let t = T(context: self)
        initObject(t)
        return t
    }
}

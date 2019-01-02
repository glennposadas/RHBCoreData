import CoreData

@objc public extension NSFetchedResultsController {
    convenience init(performing request: NSFetchRequest<ResultType>, in context: NSManagedObjectContext, section: String? = nil, cache: String? = nil) throws {
        self.init(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: section, cacheName: cache)
        try performFetch()
    }
    convenience init?(performing request: NSFetchRequest<ResultType>, in context: NSManagedObjectContext, section: String? = nil, cache: String? = nil, _ block: ((Error) -> Void)? = nil) {
        do {
            try self.init(performing: request, in: context, section: section, cache: cache)
        } catch {
            block?(error)
            return nil
        }
    }
}

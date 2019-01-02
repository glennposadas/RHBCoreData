import CoreData

public class FetchRequestBuilder<T: NSManagedObject> {
    public let request = genericFetchRequest(T.self)
    public init() {}
}

public extension FetchRequestBuilder {
    func fetch(limit: Int) -> FetchRequestBuilder<T> {
        request.fetchLimit = limit
        return self
    }

    func and(predicate: NSPredicate) -> FetchRequestBuilder<T> {
        request.predicate = request.predicate.map { NSCompoundPredicate(andPredicateWithSubpredicates:[$0, predicate]) } ?? predicate
        return self
    }

    func or(predicate: NSPredicate) -> FetchRequestBuilder<T> {
        request.predicate = request.predicate.map { NSCompoundPredicate(orPredicateWithSubpredicates:[$0, predicate]) } ?? predicate
        return self
    }

    func notPredicate() -> FetchRequestBuilder<T> {
        request.predicate = request.predicate.map { NSCompoundPredicate(notPredicateWithSubpredicate: $0) }
        return self
    }

    func sort(descriptor: NSSortDescriptor) -> FetchRequestBuilder<T> {
        request.sortDescriptors = (request.sortDescriptors ?? []) + [descriptor]
        return self
    }
}

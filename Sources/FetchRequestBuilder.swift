import CoreData

public class FetchRequestBuilder<T: NSManagedObject> {
    public static var request: NSFetchRequest<T> {
        return T.fetchRequest() as! NSFetchRequest<T>
    }
    public let request = FetchRequestBuilder<T>.request
    public init() {}
}

public extension FetchRequestBuilder {
    func modify(_ block: (NSFetchRequest<T>)->Void) -> Self {
        block(request)
        return self
    }

    func includesPropertyValues(_ value: Bool) -> Self {
        return modify { $0.includesPropertyValues = value }
    }

    func includesSubentities(_ value: Bool) -> Self {
        return modify { $0.includesSubentities = value }
    }

    func asFaults(_ value: Bool) -> Self {
        return modify { $0.returnsObjectsAsFaults = value }
    }

    func limit(_ value: Int) -> Self {
        return modify { $0.fetchLimit = value }
    }

    func batchSize(_ value: Int) -> Self {
        return modify { $0.fetchBatchSize = value }
    }

    func offset(_ value: Int) -> Self {
        return modify { $0.fetchOffset = value }
    }

    func andPredicate(_ predicate: NSPredicate) -> Self {
        return modify {
            $0.predicate = $0.predicate.map { NSCompoundPredicate(andPredicateWithSubpredicates: [$0, predicate]) } ?? predicate
        }
    }

    func addSort(_ descriptor: NSSortDescriptor) -> Self {
        return modify { $0.sortDescriptors = ($0.sortDescriptors ?? []) + [descriptor] }
    }

    func request(_ block: (NSFetchRequest<T>)->Void) -> NSFetchRequest<T> {
        return modify(block).request
    }
}

import CoreData
import RHBFoundation

public final class FetchRequestBuilder<T: NSManagedObject> {
    public let request = FetchRequest<T>.request
}

public extension FetchRequestBuilder {
    convenience init<P: NSPredicate & TypedPredicateProtocol>(predicate: P) where P.Root == T {
        self.init()
        request.predicate = predicate
    }

    convenience init<V: Comparable>(sortBy keyPath: KeyPath<T, V?>, ascending: Bool) {
        self.init()
        addSort(by: keyPath, ascending: ascending)
    }

    convenience init<V: Comparable>(sortBy keyPath: KeyPath<T, V>, ascending: Bool) {
        self.init()
        addSort(by: keyPath, ascending: ascending)
    }

    @discardableResult
    func addSort<V: Comparable>(by keyPath: KeyPath<T, V?>, ascending: Bool) -> Self {
        request.addsort(NSSortDescriptor(keyPath: keyPath, ascending: ascending))
        return self
    }

    @discardableResult
    func addSort<V: Comparable>(by keyPath: KeyPath<T, V>, ascending: Bool) -> Self {
        request.addsort(NSSortDescriptor(keyPath: keyPath, ascending: ascending))
        return self
    }
}

// MARK: - internal

@objc extension NSFetchRequest {
    func addsort(_ desc: NSSortDescriptor) {
        sortDescriptors = (sortDescriptors ?? []) + [desc]
    }
}

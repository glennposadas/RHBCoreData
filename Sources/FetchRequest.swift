import CoreData
import RHBFoundation

public enum FetchRequestWrapper<T: NSManagedObject> {}

public extension FetchRequestWrapper {
    static var request: NSFetchRequest<T> {
        // swiftlint:disable force_cast
        return T.fetchRequest() as! NSFetchRequest<T>
        // swiftlint:enable force_cast
    }
}

public class FetchRequest<T: NSManagedObject> {
    public let request = FetchRequestWrapper<T>.request
}

public extension FetchRequest {
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

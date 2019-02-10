import CoreData
import RHBFoundation

public class FetchRequest<T: NSManagedObject> {
    public static func fetchRequest() -> NSFetchRequest<T> {
        return T.fetchRequest() as! NSFetchRequest<T>
    }
    public let request = FetchRequest.fetchRequest()
    public init() {}
    convenience init<P: NSPredicate & TypedPredicateProtocol>(predicate: P) where P.Root == T  {
        self.init()
        self.predicate(predicate)
    }
}

extension FetchRequest {
    func addUnconstrainedSort<V>(by keyPath: KeyPath<T, V>, ascending: Bool) -> Self {
        let desc = NSSortDescriptor(keyPath: keyPath, ascending: ascending)
        request.sortDescriptors = (request.sortDescriptors ?? []) + [desc]
        return self
    }
}

public extension FetchRequest {
    @discardableResult
    func predicate<P: NSPredicate & TypedPredicateProtocol>(_ p: P?) -> Self where P.Root == T {
        request.predicate = p
        return self
    }

    @discardableResult
    func addSort<V: Comparable>(by keyPath: KeyPath<T, Optional<V>>, ascending: Bool) -> Self {
        return addUnconstrainedSort(by: keyPath, ascending: ascending)
    }

    @discardableResult
    func addSort<V: Comparable>(by keyPath: KeyPath<T, V>, ascending: Bool) -> Self {
        return addUnconstrainedSort(by: keyPath, ascending: ascending)
    }

    var compoundPredicate: CompoundPredicate<T>? {
        guard let pred = request.predicate else {
            return nil
        }
        return pred as? CompoundPredicate<T> ?? CompoundPredicate(type: .and, subpredicates: [pred])
    }
}

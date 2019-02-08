import CoreData
import RHBFoundation

public class FetchRequest<T: NSManagedObject> {
    public static func fetchRequest() -> NSFetchRequest<T> {
        return T.fetchRequest() as! NSFetchRequest<T>
    }
    public let request = FetchRequest<T>.fetchRequest()
    public init() {}
}

public extension FetchRequest {
    @discardableResult
    func predicate<P: NSPredicate & TypedPredicateProtocol>(_ p: P?) -> Self where P.Root == T {
        request.predicate = p
        return self
    }

    @discardableResult
    func addSortDescriptor<V: Comparable>(_ s: KeyPath<T, Optional<V>>, _ ascending: Bool = true) -> Self {
        let desc = NSSortDescriptor(keyPath: s, ascending: ascending)
        request.sortDescriptors = (request.sortDescriptors ?? []) + [desc]
        return self
    }

    @discardableResult
    func addSortDescriptor<V: Comparable>(_ s: KeyPath<T, V>, _ ascending: Bool = true) -> Self {
        let desc = NSSortDescriptor(keyPath: s, ascending: ascending)
        request.sortDescriptors = (request.sortDescriptors ?? []) + [desc]
        return self
    }

    var predicate: CompoundPredicate<T>? {
        guard let pred = request.predicate else {
            return nil
        }
        return pred as? CompoundPredicate<T> ?? CompoundPredicate(type: .and, subpredicates: [pred])
    }
}

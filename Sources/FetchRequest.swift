import CoreData
import RHBFoundation

public class FetchRequest<T: NSManagedObject> {
    public static func fetchRequest() -> NSFetchRequest<T> {
        return T.fetchRequest() as! NSFetchRequest<T>
    }

    public let request = fetchRequest()

    public init() {}
}

extension FetchRequest {
    func addsort(_ desc: NSSortDescriptor) {
        request.sortDescriptors = (request.sortDescriptors ?? []) + [desc]
    }
}

public extension FetchRequest {
    convenience init<P: NSPredicate & TypedPredicateProtocol>(predicate: P) where P.Root == T {
        self.init()
        self.predicate(predicate)
    }

    convenience init<V: Comparable>(sortBy keyPath: KeyPath<T, V?>, ascending: Bool) {
        self.init()
        addSort(by: keyPath, ascending: ascending)
    }

    convenience init<V: Comparable>(sortBy keyPath: KeyPath<T, V>, ascending: Bool) {
        self.init()
        addSort(by: keyPath, ascending: ascending)
    }

    func predicate<P: NSPredicate & TypedPredicateProtocol>(_ p: P?) where P.Root == T {
        request.predicate = p
    }

    func addSort<V: Comparable>(by keyPath: KeyPath<T, V?>, ascending: Bool) {
        addsort(NSSortDescriptor(keyPath: keyPath, ascending: ascending))
    }

    func addSort<V: Comparable>(by keyPath: KeyPath<T, V>, ascending: Bool) {
        addsort(NSSortDescriptor(keyPath: keyPath, ascending: ascending))
    }
}

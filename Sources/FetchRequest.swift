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
    func predicate<P: NSPredicate & TypedPredicateProtocol>(_ p: ()->P?) -> Self where P.Root == T {
        request.predicate = p()
        return self
    }

    var predicate: CompoundPredicate<T>? {
        guard let pred = request.predicate else {
            return nil
        }
        return pred as? CompoundPredicate<T> ?? CompoundPredicate(type: .and, subpredicates: [pred])
    }
}

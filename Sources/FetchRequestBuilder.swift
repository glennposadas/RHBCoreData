import CoreData
import RHBFoundation

public class FetchRequestBuilder<T: NSManagedObject> {
    public static var request: NSFetchRequest<T> {
        return T.fetchRequest() as! NSFetchRequest<T>
    }
    public let request = FetchRequestBuilder<T>.request
    public init() {}
}


public extension FetchRequestBuilder {
    @discardableResult
    func request(_ block: (NSFetchRequest<T>)->Void) -> NSFetchRequest<T> {
        block(request)
        return request
    }

    @discardableResult
    func withPredicate<P: NSPredicate & TypedPredicateProtocol>(_ p: P?) -> Self where P.Root == T {
        request.predicate = p
        return self
    }

    var typedPredicate: TypedCompoundPredicate<T>? {
        guard let pred = request.predicate else {
            return nil
        }
        return pred as? TypedCompoundPredicate<T> ?? TypedCompoundPredicate(type: .and, subpredicates: [pred])
    }
}

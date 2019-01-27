import CoreData

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
}

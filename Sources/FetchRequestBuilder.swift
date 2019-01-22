import CoreData

public class FetchRequestBuilder<T: NSManagedObject> {
    public static var request: NSFetchRequest<T> {
        return T.fetchRequest() as! NSFetchRequest<T>
    }
    public let request = FetchRequestBuilder<T>.request
    public init() {}
}

public extension FetchRequestBuilder {
    func limit(_ limit: Int) -> Self {
        request.fetchLimit = limit
        return self
    }

    func predicate(_ predicate: NSPredicate?) -> Self {
        request.predicate = predicate
        return self
    }

    func sort(_ descriptor: NSSortDescriptor) -> Self {
        return sort([descriptor])
    }

    func sort(_ descriptors: [NSSortDescriptor]?) -> Self {
        request.sortDescriptors = descriptors
        return self
    }

    func request(_ block: (NSFetchRequest<T>)->Void) -> NSFetchRequest<T> {
        block(request)
        return request
    }
}

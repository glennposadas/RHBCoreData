import CoreData

public enum FetchRequest<T: NSManagedObject> {}

public extension FetchRequest {
    static var request: NSFetchRequest<T> {
        // swiftlint:disable:next force_cast
        return T.fetchRequest() as! NSFetchRequest<T>
    }
}

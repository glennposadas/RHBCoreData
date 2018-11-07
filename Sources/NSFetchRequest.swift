import CoreData

public func makeFetchRequest<T: NSManagedObject>(_ t: T.Type) -> NSFetchRequest<T> {
    return T.fetchRequest() as! NSFetchRequest<T>
}

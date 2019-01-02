import CoreData

public func genericFetchRequest<T: NSManagedObject>(_ t: T.Type) -> NSFetchRequest<T> {
    return T.fetchRequest() as! NSFetchRequest<T>
}

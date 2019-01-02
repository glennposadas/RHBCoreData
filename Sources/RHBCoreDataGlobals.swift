import CoreData

public func genericFetchRequest<T: NSManagedObject>(_ t: T.Type) -> NSFetchRequest<T> {
    return T.fetchRequest() as! NSFetchRequest<T>
}

public enum FailureHandler {
    public static var shared: (Error) -> Void = { assertionFailure(String(describing: $0)) }
}


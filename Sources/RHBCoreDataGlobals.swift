import CoreData

public func genericFetchRequest<T: NSManagedObject>(_ t: T.Type) -> NSFetchRequest<T> {
    return T.fetchRequest() as! NSFetchRequest<T>
}

public var coreDataErrorBlock: (Error) -> Void = { assertionFailure(String(describing: $0)) }


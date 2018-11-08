import CoreData

//NSFetchedResultsController suck because its objective-c generic, so we wrap it
public struct FetchedData<T: NSFetchRequestResult> {
    public let controller: NSFetchedResultsController<T>
    public init(_ controller: NSFetchedResultsController<T>) {
        self.controller = controller
    }
}

public extension FetchedData {
    var sections: [NSFetchedResultsSectionInfo] {
        return controller.sections ?? []
    }
    subscript(_ indexPath: IndexPath) -> T {
        return controller.object(at: indexPath)
    }
}

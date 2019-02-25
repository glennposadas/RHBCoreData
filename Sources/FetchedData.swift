import CoreData

//NSFetchedResultsController suck because its objective-c generic, so we wrap it
public class FetchedData<T: NSFetchRequestResult> {
    public let controller: NSFetchedResultsController<T>
    
    public init(_ controller: NSFetchedResultsController<T>) {
        self.controller = controller
    }
}

public extension FetchedData {
    var sections: [NSFetchedResultsSectionInfo] {
        return controller.sections ?? []
    }

    var numberOfObjects: Int {
        return sections.reduce(0) { $0 + $1.numberOfObjects }
    }

    subscript(_ indexPath: IndexPath) -> T {
        return controller.object(at: indexPath)
    }
}

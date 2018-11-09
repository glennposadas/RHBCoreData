import CoreData

//NSFetchedResultsController suck because its objective-c generic, so we wrap it
public class FetchedResults<T: NSFetchRequestResult> {
    public let controller: NSFetchedResultsController<T>
    public let actions = FetchedResultsActions<T>()

    public init(_ controller: NSFetchedResultsController<T>) {
        controller.delegate = actions.lazyDelegate
        self.controller = controller
    }

    deinit {
        controller.delegate = nil
    }
}

public extension FetchedResults {
    var sections: [NSFetchedResultsSectionInfo] {
        return controller.sections ?? []
    }
    
    subscript(_ indexPath: IndexPath) -> T {
        return controller.object(at: indexPath)
    }
}

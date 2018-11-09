import CoreData

//NSFetchedResultsController suck because its objective-c generic, so we wrap it
public class FetchedData<T: NSFetchRequestResult> {
    public let controller: NSFetchedResultsController<T>
    public let actions = FetchedDataActions<T>()

    public init(_ controller: NSFetchedResultsController<T>) {
        controller.delegate = actions.lazyDelegate
        self.controller = controller
    }

    deinit {
        controller.delegate = nil
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

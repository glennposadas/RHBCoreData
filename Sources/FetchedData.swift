import CoreData

public class FetchedData<T: NSFetchRequestResult> {
    public let controller: NSFetchedResultsController<T>
    public let blocks: FetchedDataBlocks<T>

    public init(_ controller: NSFetchedResultsController<T>) {
        self.controller = controller
        self.blocks = FetchedDataBlocks(controller)
    }
}

public extension FetchedData {
    var controllerSections: [NSFetchedResultsSectionInfo] {
        return controller.sections ?? []
    }

    var numberOfObjects: Int {
        return controllerSections.reduce(0) { $0 + $1.numberOfObjects }
    }

    subscript(_ indexPath: IndexPath) -> T {
        return controller.object(at: indexPath)
    }
}

import CoreData

public class FetchedDataActions<T: NSFetchRequestResult> {
    public var objectChangeActions: [NSFetchedResultsChangeType: (T, IndexPath, IndexPath) -> Void] = [:]
    public var sectionChangeActions: [NSFetchedResultsChangeType: (NSFetchedResultsSectionInfo, Int) -> Void] = [:]
    public var willChange: (() -> Void)?
    public var didChange: (() -> Void)?
    public var sectionIndexTitle: ((String) -> String?)?
    
    lazy var lazyDelegate: NSFetchedResultsControllerDelegate = { FetchedResultsControllerDelegateActions(self) }()
}

class FetchedResultsControllerDelegateActions<T: NSFetchRequestResult>: NSObject, NSFetchedResultsControllerDelegate {
    weak var actions: FetchedDataActions<T>?

    init(_ actions: FetchedDataActions<T>) {
        self.actions = actions
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        actions?.didChange?()
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        actions?.willChange?()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        actions?.objectChangeActions[type]?(anObject as! T, indexPath ?? newIndexPath!, newIndexPath ?? indexPath!)
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return actions?.sectionIndexTitle?(sectionName)
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        actions?.sectionChangeActions[type]?(sectionInfo, sectionIndex)
    }
}

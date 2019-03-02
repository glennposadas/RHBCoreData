import CoreData

public class FetchedActions<T: NSFetchRequestResult> {
    public weak var controller: NSFetchedResultsController<T>? {
        didSet {
            oldValue?.delegate = nil
            controller?.delegate = delegate
        }
    }

    let delegate = FetchedResultsControllerDelegateWithBlocks<T>()

    public var blocks: FetchedBlocks<T> {
        return delegate.blocks
    }

    public init(_ controller: NSFetchedResultsController<T>) {
        self.controller = controller
        controller.delegate = delegate
    }

    deinit {
        controller?.delegate = nil
    }
}

public class FetchedBlocks<T: NSFetchRequestResult> {
    public var didChangeObject: [NSFetchedResultsChangeType: (T, IndexPath, IndexPath) -> Void] = [:]
    public var didChangeSection: [NSFetchedResultsChangeType: (NSFetchedResultsSectionInfo, Int) -> Void] = [:]
    public var willChange: (() -> Void)?
    public var didChange: (() -> Void)?
    public var sectionIndexTitle: ((String) -> String?)?
}

class FetchedResultsControllerDelegateWithBlocks<T: NSFetchRequestResult>: NSObject, NSFetchedResultsControllerDelegate {
    let blocks = FetchedBlocks<T>()

    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        blocks.didChange?()
    }

    func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        blocks.willChange?()
    }

    func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        blocks.didChangeObject[type]?(anObject as! T, indexPath ?? newIndexPath!, newIndexPath ?? indexPath!)
    }

    func controller(_: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return blocks.sectionIndexTitle?(sectionName)
    }

    func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        blocks.didChangeSection[type]?(sectionInfo, sectionIndex)
    }
}

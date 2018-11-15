import CoreData

public class FetchedActions<T: NSFetchRequestResult> {
    public let blocks = FetchedBlocks<T>()
    weak var controller: NSFetchedResultsController<T>?
    lazy var delegate: NSFetchedResultsControllerDelegate = FetchedResultsControllerDelegateWithBlocks<T>(blocks)

    public init(_ controller: NSFetchedResultsController<T>) {
        self.controller = controller
        controller.delegate = delegate
    }

    deinit {
        controller?.delegate = nil
    }
}

public class FetchedBlocks<T> {
    public var didChangeObject: [NSFetchedResultsChangeType: (T, IndexPath, IndexPath) -> Void] = [:]
    public var didChangeSection: [NSFetchedResultsChangeType: (NSFetchedResultsSectionInfo, Int) -> Void] = [:]
    public var willChange: (() -> Void)?
    public var didChange: (() -> Void)?
    public var sectionIndexTitle: ((String) -> String?)?
}

class FetchedResultsControllerDelegateWithBlocks<T>: NSObject, NSFetchedResultsControllerDelegate {
    let blocks: FetchedBlocks<T>

    init(_ actions: FetchedBlocks<T>) {
        self.blocks = actions
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blocks.didChange?()
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blocks.willChange?()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        blocks.didChangeObject[type]?(anObject as! T, indexPath ?? newIndexPath!, newIndexPath ?? indexPath!)
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return blocks.sectionIndexTitle?(sectionName)
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        blocks.didChangeSection[type]?(sectionInfo, sectionIndex)
    }
}

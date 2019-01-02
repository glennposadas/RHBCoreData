import CoreData

@objc public extension NSFetchedResultsController {
    func performFetch(failure: (Error) -> Void = FailureHandler.shared) -> Bool {
        do {
            try performFetch()
            return true
        } catch {
            failure(error)
            return false
        }
    }
}

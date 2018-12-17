import CoreData

public extension NSManagedObjectContext {
    func performTaskAndWait(_ block: @escaping (NSManagedObjectContext) -> Void) {
        performAndWait {
            block(self)
        }
    }
}

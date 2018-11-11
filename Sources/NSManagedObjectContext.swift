import Foundation
import CoreData

public extension NSManagedObjectContext {
    @discardableResult
    func performAndWaitSelf(_ block: @escaping (NSManagedObjectContext) -> Void) -> NSManagedObjectContext {
        performAndWait {
            block(self)
        }
        return self
    }
}

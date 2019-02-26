import CoreData
import RHBFoundation

public class BackgroundManagedObjectContext {
    var context: NSManagedObjectContext?

    public init(_ container: NSPersistentContainer, _ setup: (NSManagedObjectContext)->Void) {
        self.context = container.newBackgroundContext() ~ setup
    }

    deinit {
        context.map {
            context = nil
            $0.performAndWait {}
        }
    }
}

public extension BackgroundManagedObjectContext {
    func performTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        context?.perform { [weak self] in
            self?.context.map {
                block($0)
            }
        }
    }
}

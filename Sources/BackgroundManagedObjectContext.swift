import CoreData
import RHBFoundation

public class BackgroundManagedObjectContext {
    var context: NSManagedObjectContext?
    public init(_ context: NSManagedObjectContext) {
        self.context = context
    }

    deinit {
        context.map {
            context = nil
            $0.performAndWait {}
        }
    }
}

public extension BackgroundManagedObjectContext {
    convenience init(container: NSPersistentContainer, _ setup: (NSManagedObjectContext)->Void) {
        self.init(container.newBackgroundContext() ~ setup)
    }

    func performTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        context?.perform { [weak self] in
            self?.context.map {
                block($0)
            }
        }
    }
}

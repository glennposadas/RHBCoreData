import CoreData

open class BackgroundManagedObjectContext {
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
    convenience init(_ container: NSPersistentContainer, _ setup: (NSManagedObjectContext) -> Void) {
        let context = container.newBackgroundContext()
        setup(context)
        self.init(context)
    }

    func performTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        context?.perform { [weak self] in
            self?.context.map {
                block($0)
            }
        }
    }
}


import CoreData

public final class BackgroundManagedObjectContext {
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

    func write<T>(resultBlock: @escaping (Result<T, Error>) -> Void, _ taskBlock: @escaping (NSManagedObjectContext) throws -> T) {
        performTask { context in
            context.reset()
            defer { context.reset() }
            resultBlock(Result { try taskBlock(context) }
                .mapThrowable {
                    try context.saveChanges()
                    return $0
                }
            )
        }
    }

    func write(errorBlock: @escaping (Error?) -> Void, _ taskBlock: @escaping (NSManagedObjectContext) throws -> Void) {
        write(resultBlock: { result in
            do {
                try result.get()
                errorBlock(nil)
            }
            catch {
                errorBlock(error)
            }
        }, taskBlock)
    }
}


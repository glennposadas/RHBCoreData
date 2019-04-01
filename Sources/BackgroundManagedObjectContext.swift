import CoreData
import RHBFoundation

public class BackgroundManagedObjectContext {
    var context: NSManagedObjectContext?

    public init(_ container: NSPersistentContainer, _ setup: (NSManagedObjectContext) -> Void) {
        context = container.newBackgroundContext() ~ setup
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

    func write<T>(resultBlock: @escaping (Result<T, Error>) -> Void, _ taskBlock: @escaping (NSManagedObjectContext) throws -> T) {
        performTask { context in
            defer {
                context.reset()
            }
            resultBlock(Result {
                let value = try taskBlock(context)
                try context.saveChanges()
                return value
            })
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

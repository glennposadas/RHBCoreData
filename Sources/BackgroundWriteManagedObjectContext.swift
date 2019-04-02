import CoreData

public class BackgroundWriteObjectContext: BackgroundManagedObjectContext {}

public extension BackgroundWriteObjectContext {
    func write<T>(resultBlock: @escaping (Result<T, Error>) -> Void, _ taskBlock: @escaping (NSManagedObjectContext) throws -> T) {
        performTask { context in
            context.reset()
            defer { context.reset() }
            resultBlock(Result { try taskBlock(context) }.mapThrowable {
                try context.saveChanges()
                return $0
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

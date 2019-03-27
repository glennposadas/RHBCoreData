import CoreData
import RHBFoundation

open class CoreDataStack {
    public let persistentContainer: NSPersistentContainer

    public private(set) lazy var mainContext = persistentContainer.viewContext ~ {
        $0.automaticallyMergesChangesFromParent = true
    }

    public private(set) lazy var writingContext = BackgroundManagedObjectContext(persistentContainer) {
        $0.automaticallyMergesChangesFromParent = false
    }

    public private(set) lazy var readingContext = BackgroundManagedObjectContext(persistentContainer) {
        $0.automaticallyMergesChangesFromParent = true
    }

    public init(_ persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
}

public extension CoreDataStack {
    func write(errorBlock: @escaping (Error?) -> Void, taskBlock: @escaping (NSManagedObjectContext) throws -> Void) {
        write(resultBlock: { result in
            do {
                try result.get()
                errorBlock(nil)
            }
            catch {
                errorBlock(error)
            }
        }, taskBlock: taskBlock)
    }

    func write<T>(resultBlock: @escaping (Result<T, Error>) -> Void, taskBlock: @escaping (NSManagedObjectContext) throws -> T) {
        writingContext.performTask { context in
            defer {
                context.reset()
            }
            do {
                let value = try taskBlock(context)
                try context.saveChanges()
                resultBlock(.success(value))
            } catch {
                resultBlock(.failure(error))
            }
        }
    }
}

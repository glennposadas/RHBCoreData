import CoreData

public class CoreDataStack {
    public let persistentContainer: NSPersistentContainer

    public lazy var writingContext = persistentContainer.newBackgroundContext()

    public lazy var readingContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        return context
    }()

    public lazy var mainContext: NSManagedObjectContext = {
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        return persistentContainer.viewContext
    }()

    public init(_ persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
}

public extension CoreDataStack {
    convenience init(storeUrl: URL, model: NSManagedObjectModel) {
        self.init(NSPersistentContainer(storeUrl: storeUrl, model: model))
    }

    func write(task: @escaping (NSManagedObjectContext)->Void, completion: ((Error?)->Void)? = nil) {
        writingContext.performTask { context in
            task(context)
            do {
                try context.saveChanges()
            } catch {
                completion?(error)
                return
            }
            completion?(nil)
        }
    }
}

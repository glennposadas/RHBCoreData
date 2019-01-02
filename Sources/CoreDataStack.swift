import CoreData

public class CoreDataStack {
    public let persistentContainer: NSPersistentContainer

    public lazy var backgroundWritingContext = persistentContainer.newBackgroundContext()

    public lazy var backgroundReadingContext: NSManagedObjectContext = {
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
    func backgroundWriteTask(_ block: @escaping (NSManagedObjectContext)->Void) {
        backgroundWritingContext.performTask { context in
            block(context)
            context.saveChanges()
        }
    }
}

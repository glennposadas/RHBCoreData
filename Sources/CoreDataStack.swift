import CoreData

open class CoreDataStack {
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

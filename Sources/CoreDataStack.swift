import CoreData

public class CoreDataStack {
    public let persistentContainer: NSPersistentContainer

    public lazy var backgroundWritingContext = persistentContainer.newBackgroundContext()

    public lazy var backgroundReadingContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        return context
    }()

    public init(_ persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
}

public extension CoreDataStack {
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}

import CoreData
import RHBFoundation

open class CoreDataStack {
    public let readingContext: BackgroundManagedObjectContext
    public let writingContext: BackgroundManagedObjectContext
    public let mainContext: NSManagedObjectContext

    public init(_ persistentContainer: NSPersistentContainer) {
        self.mainContext = persistentContainer.viewContext ~ {
            $0.automaticallyMergesChangesFromParent = true
        }
        self.readingContext = BackgroundManagedObjectContext(container: persistentContainer) {
            $0.automaticallyMergesChangesFromParent = true
        }
        self.writingContext = BackgroundManagedObjectContext(container: persistentContainer) {
            $0.automaticallyMergesChangesFromParent = false
        }
    }

    deinit {
        shutdown()
    }
}

public extension CoreDataStack {
    func shutdown() {
        writingContext.shutdown()
        readingContext.shutdown()
    }
}

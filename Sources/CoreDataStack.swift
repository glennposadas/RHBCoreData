import CoreData
import RHBFoundation

open class CoreDataStack {
    public let mainContext: NSManagedObjectContext
    public let writingContext: BackgroundManagedObjectContext
    public let readingContext: BackgroundManagedObjectContext

    public init(_ persistentContainer: NSPersistentContainer) {
        self.mainContext = persistentContainer.viewContext ~ {
            $0.automaticallyMergesChangesFromParent = true
        }
        self.writingContext = BackgroundManagedObjectContext(
            persistentContainer.newBackgroundContext() ~ {
                $0.automaticallyMergesChangesFromParent = false
            }
        )
        self.readingContext = BackgroundManagedObjectContext(
            persistentContainer.newBackgroundContext() ~ {
                $0.automaticallyMergesChangesFromParent = true
            }
        )
    }
}

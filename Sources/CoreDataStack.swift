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

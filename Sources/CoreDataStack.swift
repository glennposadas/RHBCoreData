import CoreData
import RHBFoundation

open class CoreDataStack {
    let readingContext: NSManagedObjectContext
    let writingContext: NSManagedObjectContext
    public private(set) weak var mainContext: NSManagedObjectContext!

    public init(_ persistentContainer: NSPersistentContainer) {
        self.mainContext = persistentContainer.viewContext ~ {
            $0.automaticallyMergesChangesFromParent = true
        }
        self.readingContext = persistentContainer.newBackgroundContext() ~ {
            $0.automaticallyMergesChangesFromParent = true
        }
        self.writingContext = persistentContainer.newBackgroundContext()
    }

    deinit {
        mainContext = nil
        writingContext.performAndWait {}
        readingContext.performAndWait {}
    }
}

public extension CoreDataStack {
    func performWrite(_ block: @escaping (NSManagedObjectContext) -> Void) {
        writingContext.performTask {[weak mainContext] context in
            mainContext.map {_ in
                block(context)
            }
        }
    }

    func performRead(_ block: @escaping (NSManagedObjectContext) -> Void) {
        readingContext.performTask {[weak mainContext] context in
            mainContext.map {_ in
                block(context)
            }
        }
    }
}

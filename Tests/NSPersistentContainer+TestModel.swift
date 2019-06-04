import CoreData
import RHBCoreData
import RHBFoundation
import XCTest

extension NSPersistentContainer {
    static func testContainerByLoadingTestModelInMemory() -> NSPersistentContainer {
        return NSPersistentContainer(inMemory: .testModel) ~ {
            try! $0.loadPersistentStoresSync()
        }
    }
}

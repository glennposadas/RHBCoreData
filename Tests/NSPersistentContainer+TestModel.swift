import CoreData
import XCTest
import RHBFoundation
import RHBCoreData

extension NSPersistentContainer {
    static func testContainerByLoadingTestModelInMemory() -> NSPersistentContainer {
        return NSPersistentContainer(inMemory: .testModel) ~ {
            try! $0.loadPersistentStoresSync()
        }
    }
}

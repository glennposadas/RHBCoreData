import CoreData
import XCTest
import RHBFoundation
import RHBCoreData

extension NSPersistentContainer {
    static func testContainer() -> NSPersistentContainer {
        return NSPersistentContainer(inMemory: .testModel) ~ {
            try! $0.loadPersistentStoresSync()
        }
    }
}

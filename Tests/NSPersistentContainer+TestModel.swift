import CoreData
import XCTest
import RHBFoundation
import RHBCoreData

public extension NSPersistentContainer {
    static func testContainer() -> NSPersistentContainer {
        return NSPersistentContainer(inMemory: .testModel) ~ {
            $0.loadPersistentStores {
                XCTAssertNil($1)
            }
        }
    }
}

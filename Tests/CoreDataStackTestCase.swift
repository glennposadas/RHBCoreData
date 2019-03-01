import XCTest
import RHBCoreData
import CoreData
import RHBFoundation

class CoreDataStackTestCase: XCTestCase {
    var stack: CoreDataStack!

    override func setUp() {
        let container = NSPersistentContainer(memoryModel: .testModel)
        XCTAssert(container.loadPersistentStoresSync().isEmpty)
        stack = CoreDataStack(container)
    }

    func testSaveAndFetch() {
        let t: TestEntity = stack.mainContext.createObject() {
            $0.id = "id"
        }
        try! stack.mainContext.save()
        let fr = FetchRequest(predicate: \TestEntity.id == t.id).request
        let ent = try! stack.mainContext.fetch(fr).first
        XCTAssertNotNil(ent)
        XCTAssert(ent?.id == t.id)
    }
}

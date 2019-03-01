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

    func testCoredataDeinit() {
        var counter = 0
        let N = 50
        (0..<N).forEach { _ in
            stack.writingContext.performTask { context in
                counter += 1
                try! context.save()
            }
        }
        let coord = stack.persistentContainer.persistentStoreCoordinator
        stack = nil
        coord.persistentStores.forEach {
            try! coord.remove($0)
        }
        XCTAssert(counter < N)
    }
}

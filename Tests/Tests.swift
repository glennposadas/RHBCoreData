import XCTest
import RHBCoreData

final class RHBCoreDataTests: XCTestCase {
    static let model = NSManagedObjectModel(name: "Model", in: Bundle(for: RHBCoreDataTests.self))!
    var container: NSPersistentContainer!

    override func setUp() {
        container = NSPersistentContainer(name: "test", managedObjectModel: RHBCoreDataTests.model)
        XCTAssert(container.persistentStoreDescriptions.count == 1)
        container.persistentStoreDescriptions.forEach { store in
            try! container.persistentStoreCoordinator.destroyPersistentStore(at: store.url!, ofType: store.type)
        }
    }

    func testBasicCoreData() {
        container.loadPersistentStores { desc, err in
            print(desc)
            XCTAssertNil(err)
        }
        let fetchRequest = makeFetchRequest(TestEntity.self)
        XCTAssert(try! container.viewContext.fetch(fetchRequest).isEmpty)
        let testEntity = TestEntity(context: container.viewContext)
        try! container.viewContext.save()
        XCTAssert(try! container.viewContext.fetch(fetchRequest).count == 1)
        testEntity.delete()
        try! container.viewContext.save()
        XCTAssert(try! container.viewContext.fetch(fetchRequest).isEmpty)
    }

    func testCoreDataAsyncOk() {
        let ex = self.expectation(description: "asyncok")
        container.persistentStoreDescriptions.append(NSPersistentStoreDescription(url: URL(fileURLWithPath: "/tmp/xxx1.sqlite")))
        container.persistentStoreDescriptions.append(NSPersistentStoreDescription(url: URL(fileURLWithPath: "/tmp/xxx2.sqlite")))
        XCTAssert(container.persistentStoreDescriptions.count == 3)
        container.loadPersistentStoresAsync { errors in
            XCTAssert(errors.isEmpty)
            ex.fulfill()
        }
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testCoreDataAsyncErrors() {
        let ex = self.expectation(description: "asyncbad")
        container.persistentStoreDescriptions.append(NSPersistentStoreDescription(url: URL(fileURLWithPath: "/verybadpath/xxx1.sqlite")))
        container.persistentStoreDescriptions.append(NSPersistentStoreDescription(url: URL(fileURLWithPath: "/verybadpath/xxx2.sqlite")))
        XCTAssert(container.persistentStoreDescriptions.count == 3)
        container.loadPersistentStoresAsync { errors in
            XCTAssert(errors.count == 2)
            ex.fulfill()
        }
        self.waitForExpectations(timeout: 2, handler: nil)
    }
}

import XCTest
import RHBCoreData

final class RHBCoreDataTests: XCTestCase {
    static let model = NSManagedObjectModel(name: "Model", in: Bundle(for: RHBCoreDataTests.self))!
    static let storeUrl: URL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("test").appendingPathExtension("sqlite")

    var container: NSPersistentContainer!

    override func setUp() {
        container = NSPersistentContainer(sqliteFileUrl: RHBCoreDataTests.storeUrl, model: RHBCoreDataTests.model)
        XCTAssert(container.persistentStoreDescriptions.count == 1)
        try! container.destroyStores()
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


    func testCoreDataSyncOk() {
        XCTAssert(container.loadStoresSync().isEmpty)
    }

    func testCoreDataSyncErrors() {
        container.persistentStoreDescriptions.append(NSPersistentStoreDescription(url: URL(fileURLWithPath: "/verybadpath/xxx1.sqlite")))
        container.persistentStoreDescriptions.append(NSPersistentStoreDescription(url: URL(fileURLWithPath: "/verybadpath/xxx2.sqlite")))
        XCTAssert(container.loadStoresSync().count == 2)
    }

    func testCoreDataAsyncOk() {
        let ex = self.expectation(description: "asyncok")
        container.persistentStoreDescriptions.append(NSPersistentStoreDescription(url: URL(fileURLWithPath: "/tmp/xxx1.sqlite")))
        container.persistentStoreDescriptions.append(NSPersistentStoreDescription(url: URL(fileURLWithPath: "/tmp/xxx2.sqlite")))
        XCTAssert(container.persistentStoreDescriptions.count == 3)
        container.loadStoresAsync { errors in
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
        container.loadStoresAsync { errors in
            XCTAssert(errors.count == 2)
            ex.fulfill()
        }
        self.waitForExpectations(timeout: 2, handler: nil)
    }
}

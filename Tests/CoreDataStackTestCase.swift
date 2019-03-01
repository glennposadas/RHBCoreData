import XCTest
import RHBCoreData
import CoreData
import RHBFoundation

class CoreDataStackTestCase: XCTestCase {
    var container: NSPersistentContainer!
    var stack: CoreDataStack!

    override func setUp() {
        container = NSPersistentContainer(memoryModel: .testModel)
        XCTAssert(container.loadPersistentStoresSync().isEmpty)
        stack = CoreDataStack(container)
    }

    func testCRUD() {
        stack.writingContext.performTask { context in
            context.createObject() { (testEntity: TestEntity) in
                testEntity.id = #function
            }
            try! context.saveChanges()
        }

        stack.writingContext.performTask { context in
            let fetchRequest = FetchRequest(predicate: \TestEntity.id == #function).request
            let testEntity = try! context.fetch(fetchRequest).first!
            XCTAssert(testEntity.id == #function)
            testEntity.id = nil
            try! context.saveChanges()
        }

        stack.writingContext.performTask { context in
            let fetchRequest = FetchRequest(predicate: \TestEntity.id == nil).request
            let testEntity = try! context.fetch(fetchRequest).first!
            XCTAssert(testEntity.id == nil)
            testEntity.deleteFromManagedObjectContext()
            try! context.saveChanges()
        }

        stack.writingContext.performTask { context in
            let fetchRequest = FetchRequest<TestEntity>.fetchRequest()
            XCTAssert(try! context.fetch(fetchRequest).isEmpty)
        }

        let ex = expectation(description: #function)
        stack.writingContext.performTask { _ in
            ex.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
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
        try! coord.removeStores()
        XCTAssert(counter < N)
    }

    func testCoreDataAsyncOk() {
        let ex = expectation(description: #function)
        try! container.persistentStoreCoordinator.removeStores()
        container.persistentStoreDescriptions.append(NSPersistentStoreDescription(url: NSPersistentContainer.defaultDirectoryURL().appendingPathComponent(#function)))
        XCTAssert(container.persistentStoreDescriptions.count == 2)
        container.loadPersistentStoresAsync { errors in
            XCTAssert(errors.isEmpty)
            ex.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCoreDataAsyncErrors() {
        let ex = expectation(description: #function)
        try! container.persistentStoreCoordinator.removeStores()
        container.persistentStoreDescriptions.append(NSPersistentStoreDescription(url: URL(fileURLWithPath: "/verybadpath/xxx1.sqlite")))
        XCTAssert(container.persistentStoreDescriptions.count == 2)
        container.loadPersistentStoresAsync { errors in
            XCTAssert(errors.count == 1)
            ex.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCoreDataSyncErrors() {
        try! container.persistentStoreCoordinator.removeStores()
        container.persistentStoreDescriptions.append(NSPersistentStoreDescription(url: URL(fileURLWithPath: "/verybadpath/xxx1.sqlite")))
        XCTAssert(container.loadPersistentStoresSync().count == 1)
    }
}

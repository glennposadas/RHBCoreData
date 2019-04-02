import CoreData
import RHBCoreData
import RHBFoundation
import RHBFoundationTestUtilities
import XCTest

extension CoreDataStack {
    func createTestEntity(id: String, _ block: @escaping (Result<TestEntity, Error>) -> Void) {
        writingContext.write(resultBlock: block) { context in
            context.createObject {
                $0.id = id
            }
        }
    }
}

class CoreDataStackTestCase: XCTestCase {
    var container: NSPersistentContainer!
    var stack: CoreDataStack!
    let errorBlock: (Error?) -> Void = {
        XCTAssertNil($0)
    }

    override func setUp() {
        container = NSPersistentContainer(memoryModel: .testModel)
        XCTAssert(container.loadPersistentStoresSync().isEmpty)
        stack = CoreDataStack(container)
    }

    func testExisting() {
        let ex = expectation(description: #function)
        stack.createTestEntity(id: "1") { result in
            let ent = try! result.get()
            self.stack.writingContext.write(errorBlock: self.errorBlock) { context in
                let ent2 = context.existing(ent)
                XCTAssertNotNil(ent2)
                ent2?.deleteFromManagedObjectContext()
            }
            self.stack.writingContext.write(errorBlock: self.errorBlock) { context in
                XCTAssertNil(context.existing(ent))
                ex.fulfill()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCRUD() {
        let errorBlock: (Error?) -> Void = {
            XCTAssertNil($0)
        }

        stack.createTestEntity(id: #function) { result in
            _=try! result.get()
        }

        stack.writingContext.write(errorBlock: errorBlock) { context in
            let fetchRequest = FetchRequest(predicate: \TestEntity.id == #function).request
            let testEntity = try! context.fetch(fetchRequest).first!
            XCTAssert(testEntity.id == #function)
            testEntity.id = nil
        }

        stack.writingContext.write(errorBlock: errorBlock) { context in
            let fetchRequest = FetchRequest(predicate: \TestEntity.id == nil).request
            let testEntity = try! context.fetch(fetchRequest).first!
            XCTAssert(testEntity.id == nil)
            testEntity.deleteFromManagedObjectContext()
        }

        let ex = expectation(description: #function)
        stack.writingContext.write(errorBlock: errorBlock) { context in
            let fetchRequest = FetchRequest<TestEntity>.fetchRequest()
            XCTAssert(try! context.fetch(fetchRequest).isEmpty)
            ex.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCoredataDeinit() {
        var counter = 0
        let N = 50
        (0 ..< N).forEach { _ in
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
        container.loadPersistentStoresAsync { result in
            XCTAssert(try! result.get() == self.container)
            ex.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCoreDataAsyncErrors() {
        let ex = expectation(description: #function)
        try! container.persistentStoreCoordinator.removeStores()
        container.persistentStoreDescriptions.append(NSPersistentStoreDescription(url: URL(fileURLWithPath: "/verybadpath/xxx1.sqlite")))
        XCTAssert(container.persistentStoreDescriptions.count == 2)
        container.loadPersistentStoresAsync { result in
            do {
                _ = try result.get()
            } catch {
                ex.fulfill()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCoreDataSyncErrors() {
        try! container.persistentStoreCoordinator.removeStores()
        container.persistentStoreDescriptions.append(NSPersistentStoreDescription(url: URL(fileURLWithPath: "/verybadpath/xxx1.sqlite")))
        XCTAssert(container.loadPersistentStoresSync().count == 1)
    }

    func testBackgroundFetchedActionsInsert() {
        let ex = expectation(description: #function)
        let fetchRequest = FetchRequest(sortBy: \TestEntity.id, ascending: true).request
        var data: FetchedData<TestEntity>!
        stack.readingContext.performTask { context in
            let cont = context.createFetchedResultsController(request: fetchRequest)
            try! cont.performFetch()
            data = FetchedData(cont)
            data.blocks.didChange = {
                ex.fulfill()
                XCTAssert(cont.sections?.first?.numberOfObjects == 1)
            }
            data.blocks.didChangeObject[.insert] = { ent, _, _ in
                XCTAssert(ent.id == #function)
            }
            self.stack.writingContext.performTask { context in
                context.createObject() { (testEntity: TestEntity) in
                    testEntity.id = #function
                }
                try! context.saveChanges()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFulfiller() {
        let N = 10
        (0 ..< N * 2).forEach { index in
            let ful = expectation(description: "\(#function) \(index)").fulfiller
            if index.isMultiple(of: 2) {
                return
            }
            stack.writingContext.performTask { context in
                context.createObject { (obj: TestEntity) in
                    obj.id = #function
                }
                try! context.save()
                ful.noop()
            }
        }
        waitForExpectations(timeout: 1) {
            XCTAssertNil($0)
            XCTAssert(try! self.stack.mainContext.fetch(TestEntity.fetchRequest()).count == N)
        }
    }

    func testFetchedData() {
        let fetchRequest = FetchRequest(sortBy: \TestEntity.id, ascending: true).request
        let controller = stack.mainContext.createFetchedResultsController(request: fetchRequest)
        try! controller.performFetch()
        let fetchedData = FetchedData(controller)

        var willed = 0
        var dided = 0
        var moved = false
        var updated = false
        var inserted = false
        var deleted = false
        fetchedData.blocks.willChange = {
            XCTAssert(willed == dided)
            willed += 1
        }
        fetchedData.blocks.didChange = {
            dided += 1
            XCTAssert(willed == dided)
        }
        fetchedData.blocks.didChangeObject[.insert] = { entity, path1, path2 in
            XCTAssertEqual(try! self.container.viewContext.existingObject(with: entity.objectID), entity)
            XCTAssert(path1 == path2)
            XCTAssertEqual(entity, fetchedData[path1])
            inserted = true
        }
        fetchedData.blocks.didChangeObject[.delete] = { entity, path1, path2 in
            XCTAssertEqual(try! self.container.viewContext.existingObject(with: entity.objectID), entity)
            XCTAssert(path1 == path2)
            XCTAssertFalse(fetchedData.controller.fetchedObjects!.contains(entity))
            deleted = true
        }
        fetchedData.blocks.didChangeObject[.update] = { entity, path1, path2 in
            XCTAssertEqual(try! self.container.viewContext.existingObject(with: entity.objectID), entity)
            XCTAssert(path1 == path2)
            XCTAssertEqual(entity, fetchedData[path1])
            updated = true
        }
        fetchedData.blocks.didChangeObject[.move] = { entity, path1, path2 in
            XCTAssertEqual(try! self.container.viewContext.existingObject(with: entity.objectID), entity)
            XCTAssert(path1 != path2)
            XCTAssertEqual(entity, fetchedData[path2])
            moved = true
        }

        XCTAssert(fetchedData.controller.sections?.count == 1)
        XCTAssert(fetchedData.controller.sections?.first?.numberOfObjects == 0)

        let t1 = TestEntity(context: container.viewContext)
        t1.id = "a"
        let t5 = TestEntity(context: container.viewContext)
        t5.id = "b"
        XCTAssert(!inserted)
        try! container.viewContext.save()
        XCTAssert(inserted)
        XCTAssert(fetchedData.controller.sections?.first?.numberOfObjects == 2)

        t1.text = UUID().uuidString
        XCTAssert(!updated)
        try! container.viewContext.save()
        XCTAssert(updated)

        t1.id = "c"
        XCTAssert(!moved)
        try! container.viewContext.save()
        XCTAssert(moved)

        t1.deleteFromManagedObjectContext()
        XCTAssert(!deleted)
        try! container.viewContext.save()
        XCTAssert(deleted)
        XCTAssert(fetchedData.controller.sections?.first?.numberOfObjects == 1)

        let ex = expectation(description: #function)
        stack.writingContext.performTask { context in
            let obj = try! context.refetch([t5]).first!
            obj.deleteFromManagedObjectContext()
            try! context.save()
            DispatchQueue.main.async {
                ex.fulfill()
            }
        }

        waitForExpectations(timeout: 1) { err in
            XCTAssertNil(err)
            XCTAssert(fetchedData.controller.sections?.first?.numberOfObjects == 0)
            XCTAssert(willed > 0 && dided > 0 && willed == dided)
        }
    }

    func testSelfIn() {
        let ex = expectation(description: #function)

        var ent: TestEntity!

        self.container.newBackgroundContext() ~ { context in
            context.performAndWait {
                ent = TestEntity(context: context)
                try! context.save()
            }
        }

        DispatchQueue.global().sync {
            XCTAssertNotNil(self.container.newBackgroundContext().existing(ent))
        }

        DispatchQueue.global().async {
            let fr2 = FetchRequest<TestEntity>.fetchRequest()
            fr2.predicate = {
                let ex1 = NSExpression(forKeyPath: \TestEntity.self)
                let ex2 = NSExpression(forConstantValue: [ent])
                return NSComparisonPredicate(leftExpression: ex1, rightExpression: ex2, modifier: .direct, type: .in)
            }()
            fr2.returnsObjectsAsFaults = true

            let fr1 = FetchRequest<TestEntity>.fetchRequest()
            fr1.predicate = {
                let ex1 = NSExpression(format: "self")
                let ex2 = NSExpression(forConstantValue: [ent])
                return NSComparisonPredicate(leftExpression: ex1, rightExpression: ex2, modifier: .direct, type: .in)
            }()
            fr1.returnsObjectsAsFaults = true

            self.stack.readingContext.performTask {
                XCTAssert(try! $0.fetch(fr1).first?.objectID == ent.objectID)
                XCTAssert(try! $0.fetch(fr2).first?.objectID == ent.objectID)
                XCTAssert(try! $0.refetch([ent]).first?.objectID == ent.objectID)
                XCTAssert($0.existing(ent)?.objectID == ent.objectID)
                ex.fulfill()
            }
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}

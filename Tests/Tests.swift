import XCTest
import RHBCoreData

final class RHBCoreDataTests: XCTestCase {
    static let model = NSManagedObjectModel(name: "Model", in: Bundle(for: RHBCoreDataTests.self))!
    static let storeUrl: URL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("test").appendingPathExtension("sqlite")

    var container: NSPersistentContainer!

    override func setUp() {
        container = NSPersistentContainer(fileUrl: RHBCoreDataTests.storeUrl, model: RHBCoreDataTests.model)
        XCTAssert(container.persistentStoreDescriptions.count == 1)
        try! container.destroyStores()
    }

    func testModelLoading() {
        XCTAssertNotNil(NSManagedObjectModel(name: "Model", in: Bundle(for: RHBCoreDataTests.self)))
        XCTAssertNil(NSManagedObjectModel(name: "no_Model", in: Bundle(for: RHBCoreDataTests.self)))
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

    func testSections() {
        XCTAssert(container.loadStoresSync().isEmpty)
        container.viewContext.automaticallyMergesChangesFromParent = true
        let fr = makeFetchRequest(TestSection.self)
        fr.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TestSection.section), ascending: true),
            NSSortDescriptor(key: #keyPath(TestSection.index), ascending: true)
        ]

        let controller = try! NSFetchedResultsController(performing: fr, in: container.viewContext, section: #keyPath(TestSection.section))
        let fd = FetchedData(controller)
        fd.actions.sectionIndexTitle = { name in
            return "title\(name)"
        }
        fd.actions.sectionChangeActions[.insert] = { info, index in
            //XCTAssertEqual(info, fd.sections[index])
            XCTAssert(info.name == "section\(index)")
            XCTAssert(info.indexTitle == "title\(info.name)")
        }
        
        XCTAssert(fd.sections.count == 0)

        let sec = 3
        (0..<sec).forEach {
            let entity = TestSection(context: container.viewContext)
            entity.section = "section\($0)"
            entity.index = Int64($0)
            try! container.viewContext.save()
        }

        XCTAssert(fd.sections.count == sec)
        XCTAssert(fd.sections[0].numberOfObjects == 1)

        let entity01 = TestSection(context: container.viewContext)
        entity01.section = "section0"
        entity01.index = Int64(1)
        try! container.viewContext.save()

        XCTAssert(fd.sections.count == sec)
        XCTAssert(fd.sections[0].numberOfObjects == 2)
    }

    func testFetchedData() {
        XCTAssert(container.loadStoresSync().isEmpty)
        container.viewContext.automaticallyMergesChangesFromParent = true

        let fetchedRequest = makeFetchRequest(TestEntity.self)
        fetchedRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TestEntity.number), ascending: true)
        ]
        let fetchedData = FetchedData(try! NSFetchedResultsController(performing: fetchedRequest, in: container.viewContext))

        var willed = 0
        var dided = 0
        var moved = false
        var updated = false
        var inserted = false
        var deleted = false
        fetchedData.actions.willChange = {
            XCTAssert(willed == dided)
            willed+=1
        }
        fetchedData.actions.didChange = {
            dided+=1
            XCTAssert(willed == dided)
        }
        fetchedData.actions.objectChangeActions[.insert] = { entity, path1, path2 in
            let obj = try! self.container.viewContext.existingObject(with: entity.objectID)
            XCTAssertEqual(obj, entity)
            XCTAssert(path1 == path2)
            XCTAssertEqual(entity, fetchedData[path1])
            inserted = true
        }
        fetchedData.actions.objectChangeActions[.delete] = { entity, path1, path2 in
            let obj = try! self.container.viewContext.existingObject(with: entity.objectID)
            XCTAssertEqual(obj, entity)
            XCTAssert(path1 == path2)
            deleted = true
        }
        fetchedData.actions.objectChangeActions[.update] = { entity, path1, path2 in
            let obj = try! self.container.viewContext.existingObject(with: entity.objectID)
            XCTAssertEqual(obj, entity)
            XCTAssert(path1 == path2)
            XCTAssertEqual(entity, fetchedData[path1])
            updated = true
        }
        fetchedData.actions.objectChangeActions[.move] = { entity, path1, path2 in
            let obj = try! self.container.viewContext.existingObject(with: entity.objectID)
            XCTAssertEqual(obj, entity)
            XCTAssertEqual(entity, fetchedData[path2])
            moved = true
        }

        XCTAssert(fetchedData.sections.count == 1)
        XCTAssert(fetchedData.sections.first?.numberOfObjects == 0)

        let t1 = TestEntity(context: container.viewContext)
        t1.number = 1
        inserted = false
        try! container.viewContext.save()
        XCTAssert(inserted)
        XCTAssert(fetchedData.sections.first?.numberOfObjects == 1)

        let t5 = TestEntity(context: container.viewContext)
        t5.number = 5
        try! container.viewContext.save()
        XCTAssert(fetchedData.sections.first?.numberOfObjects == 2)

        t1.number = 2
        updated = false
        moved = false
        try! container.viewContext.save()
        XCTAssert(updated)
        XCTAssertFalse(moved)

        t1.number = 10
        updated = false
        moved = false
        try! container.viewContext.save()
        XCTAssert(moved)
        XCTAssertFalse(updated)

        t1.delete()
        try! container.viewContext.save()
        XCTAssert(deleted)
        XCTAssert(fetchedData.sections.first?.numberOfObjects == 1)

        XCTAssert(willed > 0 && dided > 0 && willed == dided)

        let ex = expectation(description: "back")
        container.performBackgroundTask { context in
            let obj = try! context.existingObject(with: t5.objectID)
            XCTAssert(obj.managedObjectContext == context)
            obj.delete()
            try! context.save()
            DispatchQueue.main.async {
                ex.fulfill()
            }
        }

        waitForExpectations(timeout: 1) { err in
            XCTAssertNil(err)
            XCTAssert(fetchedData.sections.first?.numberOfObjects == 0)
        }
    }
}

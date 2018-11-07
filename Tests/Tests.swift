import XCTest
import RHBCoreData

final class RHBCoreDataTests: XCTestCase {
    func testRHBCoreData() {
        let model = NSManagedObjectModel(name: "Model", in: Bundle(for: type(of: self)))!
        let container = NSPersistentContainer(name: "test", managedObjectModel: model)
        XCTAssert(container.persistentStoreDescriptions.count == 1)
        container.persistentStoreDescriptions.forEach { store in
            try! container.persistentStoreCoordinator.destroyPersistentStore(at: store.url!, ofType: store.type, options: nil)
        }
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
}

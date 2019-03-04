import CoreData
import RHBCoreData
import RHBFoundation
import XCTest
/*
 final class FetchedResultsTests: CoreDataContainerTestCase {
 func testSections() {
 let fetchRequest: NSFetchRequest<TestSection> = TestSection.fetchRequest()
 fetchRequest.sortDescriptors = [
 NSSortDescriptor(keyPath: \TestSection.section, ascending: true),
 NSSortDescriptor(keyPath: \TestSection.index, ascending: true)
 ]
 let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: container.viewContext, sectionNameKeyPath: #keyPath(TestSection.section), cacheName: nil)
 try! controller.performFetch()
 let fd = FetchedData(controller)
 let fa = FetchedActions(controller)
 fa.blocks.sectionIndexTitle = { name in
 return "title\(name)"
 }
 fa.blocks.didChangeSection[.insert] = { info, index in
 XCTAssertEqual(info.name, fd.sections[index].name)
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
 }
 */

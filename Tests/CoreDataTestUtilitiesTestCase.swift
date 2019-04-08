import CoreData
import RHBCoreDataTestUtilities
import XCTest

class CoreDataTestUtilitiesTestCase: XCTestCase {
    func testModel() {
        NSManagedObjectModel.testModel.entities.forEach {
            EntityChecker(entityDescription: $0).checkEntity()
        }
    }
}

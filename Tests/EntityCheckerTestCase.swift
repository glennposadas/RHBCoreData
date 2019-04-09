import CoreData
import RHBCoreDataTestUtilities
import XCTest

class EntityCheckerTestCase: XCTestCase {
    func testModel() {
        NSManagedObjectModel.testModel.entities.forEach {
            EntityChecker(entityDescription: $0).checkEntity()
        }
    }
}

import CoreData

class TestEntity: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var deca: Decimal
}

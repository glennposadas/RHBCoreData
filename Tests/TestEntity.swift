import CoreData

@objc class TestEntity: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var deca: Decimal
    @NSManaged public var flag: Bool
}

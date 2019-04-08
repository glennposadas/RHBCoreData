import CoreData

@objc(TestEntity)
public final class TestEntity: NSManagedObject {
    @NSManaged public var id: String!
    @NSManaged public var text: String!
}

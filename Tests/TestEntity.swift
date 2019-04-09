import CoreData

class TestEntity: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var deca: Decimal
}

extension TestEntity {
    static func random(context: NSManagedObjectContext) -> TestEntity {
        return context.createObject {
            $0.id = UUID().uuidString
            $0.text = UUID().uuidString
            $0.deca = Decimal(arc4random())
        }
    }
}

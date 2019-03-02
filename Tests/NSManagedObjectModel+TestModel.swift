import CoreData
import RHBFoundation

extension NSManagedObjectModel {
    static let testModel = NSManagedObjectModel() ~ {
        $0.entities = [
            NSEntityDescription() ~ {
                $0.name = String(describing: TestEntity.self)
                $0.managedObjectClassName = String(reflecting: TestEntity.self)
                $0.properties = [
                    NSAttributeDescription() ~ {
                        $0.name = #keyPath(TestEntity.id)
                        $0.attributeType = .stringAttributeType
                    },
                    NSAttributeDescription() ~ {
                        $0.name = #keyPath(TestEntity.text)
                        $0.attributeType = .stringAttributeType
                    },
                ]
            },
        ]
    }
}

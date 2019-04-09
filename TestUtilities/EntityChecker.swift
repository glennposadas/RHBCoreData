import XCTest
import CoreData

public class EntityChecker {
    let entityDescription: NSEntityDescription
    public init(entityDescription: NSEntityDescription) {
        self.entityDescription = entityDescription
    }
}

public extension EntityChecker {
    func checkEntity() {
        XCTAssert(Int.bitWidth == 64)
        checkForUnmatchedProperties()
        checkIfTypeFromCoreDataAttributesMatchesTypeInClass()
    }
}

extension objc_property_t {
    func typeInfo() -> String {
        return NSString(utf8String: property_getAttributes(self)!)! as String
    }
    func propertyName() -> String {
        return NSString(utf8String: property_getName(self))! as String
    }
}

extension NSManagedObject {
    static func propertyList() -> [objc_property_t] {
        var count32 = UInt32()
        guard
            self != NSManagedObject.self,
            let classPropertyList = class_copyPropertyList(self, &count32),
            count32 > 0 else {
                return []
        }
        return (0..<Int(count32)).map { classPropertyList[$0] } + (superclass() as! NSManagedObject.Type).propertyList()
    }
}


extension EntityChecker {
    var classPropertiesByName: [String: objc_property_t] {
        let classType = NSClassFromString(entityDescription.managedObjectClassName!)! as! NSManagedObject.Type
        return Dictionary(uniqueKeysWithValues: classType.propertyList().map {($0.propertyName(), $0)})
    }
    
    func checkForUnmatchedProperties() {
        let set1 = Set(classPropertiesByName.keys)
        let set2 = Set(entityDescription.propertiesByName.keys)
        XCTAssert(set1 == set2, "Names must match for entity \(entityDescription.name!) difference is: \(set1.symmetricDifference(set2))")
    }

    func checkValueTypeNotOptional(_ attributeDescription: NSAttributeDescription, _ typeInfoInClass: String) {
        if attributeDescription.isOptional {
            XCTAssert(typeInfoInClass.hasSuffix(",C"), "Value types should not be optional in entity: \(entityDescription.name!) property: \(attributeDescription.name)")
        }
    }

    func checkIfTypeFromCoreDataMatchesTypeInClass(_ attributeDescription: NSAttributeDescription, _ typeInfoInClass: String) {
        switch attributeDescription.attributeType {
        case .floatAttributeType:
            fallthrough
        case .integer16AttributeType:
            fallthrough
        case .integer32AttributeType:
            XCTFail("Should use 64-bit types in entity: \(entityDescription.name!) property: \(attributeDescription.name) ")
        case .integer64AttributeType:
            XCTAssert(typeInfoInClass.hasPrefix("Tq"), "Should use Int in entity: \(entityDescription.name!) property: \(attributeDescription.name) type in class: \(typeInfoInClass)")
        case .doubleAttributeType:
            XCTAssert(typeInfoInClass.hasPrefix("Td"), "Should use Double in entity: \(entityDescription.name!) property: \(attributeDescription.name) type in class: \(typeInfoInClass)")
        case .booleanAttributeType:
            let boolPrefix: String = {
                #if os(macOS)
                return "Tc"
                #else
                return "TB"
                #endif
            }()
            XCTAssert(typeInfoInClass.hasPrefix(boolPrefix), "Should use Bool in entity: \(entityDescription.name!) property: \(attributeDescription.name) type in class: \(typeInfoInClass)")
        case .UUIDAttributeType:
            XCTAssert(typeInfoInClass.hasPrefix("T@\"NSUUID\""), "Should use UUID in entity: \(entityDescription.name!) property: \(attributeDescription.name) type in class: \(typeInfoInClass)")
        case .stringAttributeType:
            XCTAssert(typeInfoInClass.hasPrefix("T@\"NSString\""), "Should use String in entity: \(entityDescription.name!) property: \(attributeDescription.name) type in class: \(typeInfoInClass)")
        case .URIAttributeType:
            XCTAssert(typeInfoInClass.hasPrefix("T@\"NSURL\""), "Should use Url in entity: \(entityDescription.name!) property: \(attributeDescription.name) type in class: \(typeInfoInClass)")
        case .dateAttributeType:
            XCTAssert(typeInfoInClass.hasPrefix("T@\"NSDate\"") || typeInfoInClass.hasPrefix("Td") , "Should use Date or TimeInterval in entity: \(entityDescription.name!) property: \(attributeDescription.name) type in class: \(typeInfoInClass)")
        case .binaryDataAttributeType:
            XCTAssert(typeInfoInClass.hasPrefix("T@\"NSData\""), "Should use Data in entity: \(entityDescription.name!) property: \(attributeDescription.name) type in class: \(typeInfoInClass)")
        case .transformableAttributeType:
            let classes = ["Set", "Array", "Dictionary"]
            let classPrefix = classes.first { attributeDescription.attributeValueClassName!.hasPrefix($0) }
            XCTAssertNotNil(classPrefix, "Class should be one of \(classes) in entity: \(entityDescription.name!) property: \(attributeDescription.name) type in class: \(typeInfoInClass)")
            XCTAssert(typeInfoInClass.hasPrefix("T@\"NS\(classPrefix!)\""), "Should use type \(classPrefix!) in entity: \(entityDescription.name!) property: \(attributeDescription.name) type in class: \(typeInfoInClass)")
        case .decimalAttributeType:
            XCTAssert(typeInfoInClass.hasPrefix("T{"), "Should use Decimal in entity: \(entityDescription.name!) property: \(attributeDescription.name) type in class: \(typeInfoInClass)")
        case .objectIDAttributeType:
            XCTFail("Object ID can not be used in core data in entity: \(entityDescription.name!) property: \(attributeDescription.name)")
        case .undefinedAttributeType:
            XCTFail("Undefined type in entity: \(entityDescription.name!) property: \(attributeDescription.name)")
        @unknown default:
            XCTFail("New type needs testing in entity: \(entityDescription.name!) property: \(attributeDescription.name) type in coredata: \(attributeDescription.attributeValueClassName!)")
        }
    }

    func checkIfTypeFromCoreDataAttributesMatchesTypeInClass() {
        entityDescription.attributesByName.values.forEach { attributeDescription in
            if let propertyTypeInfo = classPropertiesByName[attributeDescription.name]?.typeInfo() {
                checkValueTypeNotOptional(attributeDescription, propertyTypeInfo)
                checkIfTypeFromCoreDataMatchesTypeInClass(attributeDescription, propertyTypeInfo)
            }
        }
    }
}

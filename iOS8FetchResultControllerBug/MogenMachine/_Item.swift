// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Item.swift instead.

import Foundation
import CoreData

public enum ItemAttributes: String {
    case date = "date"
    case date_section_title = "date_section_title"
    case is_read = "is_read"
    case message = "message"
    case title = "title"
}

public class _Item: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Item"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Item.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var date: NSDate?

    @NSManaged public
    var date_section_title: String?

    @NSManaged public
    var is_read: NSNumber?

    @NSManaged public
    var message: String?

    @NSManaged public
    var title: String?

    // MARK: - Relationships

}


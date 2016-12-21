import Foundation
import UIKit
import CoreData

@objc(Item)
public class Item: _Item {
    var isRead: Bool {
        get {
            if let is_read = is_read {
                return Bool(is_read)
            }
            
            return false
        }
        set {
            is_read = NSNumber(bool: newValue)
        }
    }
    
    override public var date_section_title: String? {
        get {
            if let date = date {
                return dateFormatter.stringFromDate(date)
            } else {
                return nil
            }
        }
        set {
            //noop
        }
    }
    
    public override var description: String {
        return "\(date): \(title) - \(message) (\(isRead))"
    }
}

public class ItemService {
    var itemCounter = 0
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    func addItem(date: NSDate) {
        let item = Item(managedObjectContext: appDelegate.managedObjectContext)!
        item.title = "Title \(itemCounter)"
        item.message = "Message \(itemCounter)"
        item.is_read = 0
        item.date = date
        
        itemCounter += 1
        
        appDelegate.saveContext()
    }
    
    func printItems() {
        let request = NSFetchRequest(entityName: Item.entityName())
        request.sortDescriptors = [
            NSSortDescriptor(key: ItemAttributes.date.rawValue, ascending: false)
        ]
        do{
            let fetchedObjects = try appDelegate.managedObjectContext.executeFetchRequest(request) as? [Item]
            if let fetchedObjects = fetchedObjects {
                NSLog("Printing Items...")
                for object in fetchedObjects {
                    NSLog("%@", object)
                }
            }
        } catch {
            NSLog("Error: \(error)")
        }
    }
}

let itemService = ItemService()

let dateFormatter: NSDateFormatter = {
    let df = NSDateFormatter()
    df.dateFormat = "MM/dd/yyyy"
    return df
}()
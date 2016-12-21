import Foundation

@objc(Item)
public class Item: _Item {
    var isRead: Bool {
        if let is_read = is_read {
            return Bool(is_read)
        }
        
        return false
    }
    
    override var date_section_title: String? {
        get {
            return 
        }
    }
    
    static func createOrUpdate() {
        
    }
}
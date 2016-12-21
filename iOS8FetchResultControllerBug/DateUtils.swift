//
//  DateUtils.swift
//  iOS8FetchResultControllerBug
//
//  Created by Yu, William on 12/10/16.
//  Copyright © 2016 iwllyu. All rights reserved.
//

import Foundation

public class DateFormatters {
    public static var sectionDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.timeZone = NSTimeZone.systemTimeZone()
        return formatter
    }()
    
    public static var shortDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.timeZone = NSTimeZone.systemTimeZone()
        return formatter
    }()
}

extension NSDate {
    ///yyyy/MM/dd so dates will be sorted correctly in table views
    func getSectionTitle() -> String {
        return DateFormatters.sectionDateFormatter.stringFromDate(self)
    }
    
    ///MM/dd/yyyy
    func getDisplayString() -> String {
        return DateFormatters.shortDateFormatter.stringFromDate(self)
    }
    
    class func getSectionDate(dateString:String?) -> NSDate? {
        guard let dateString = dateString else {
            return nil
        }
        return DateFormatters.sectionDateFormatter.dateFromString(dateString)
    }
    
    
}
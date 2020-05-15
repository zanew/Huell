//
//  Date+DayAfter.swift
//  Sol
//
//  Created by Zane Whitney on 6/11/19.
//  Copyright © 2019 Kitsch. All rights reserved.
//

import Foundation

extension Date {
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
    
    func relative(toTimeZone timeZone: TimeZone) -> Date {
        var dstOffset: TimeInterval = 0
        
        let respectsDST = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.respectsDSTKey)
        
        if respectsDST {
            dstOffset = timeZone.daylightSavingTimeOffset()
        }
        
        return Calendar.current.date(byAdding: .second, value: Int(TimeInterval(timeZone.secondsFromGMT()) + dstOffset), to: self)!
    }
    
    var dayAfter: Date {
         Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    
    func daysAfter(_ numDays: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: numDays, to: self)!
    }
    
    // returns the date that lies in between date1 and date2
    func dateBetween(otherDate: Date) -> Date {
        var earlierDate: Date?
        var laterDate: Date?
        
        if otherDate > self {
            laterDate = otherDate
            earlierDate = self
        } else if self > otherDate {
            laterDate = self
            earlierDate = otherDate
        } else {
            return self
        }
        
        let secondsBetween = laterDate!.timeIntervalSince(earlierDate!)
        let halfSeconds = (secondsBetween / 2)
        let midDate = earlierDate!.addingTimeInterval(halfSeconds)
        
        return midDate
    }
}

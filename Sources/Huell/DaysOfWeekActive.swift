//
//  DaysOfWeekActive.swift
//  
//
//  Created by Zane Whitney on 5/14/20.
//

import Foundation

public struct DaysOfWeekActive: OptionSet {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let sunday = DaysOfWeekActive(rawValue: 1 << 0)
    public static let monday = DaysOfWeekActive(rawValue: 1 << 1)
    public static let tuesday = DaysOfWeekActive(rawValue: 1 << 2)
    public static let wednesday = DaysOfWeekActive(rawValue: 1 << 3)
    public static let thursday = DaysOfWeekActive(rawValue: 1 << 4)
    public static let friday = DaysOfWeekActive(rawValue: 1 << 5)
    public static let saturday = DaysOfWeekActive(rawValue: 1 << 6)
    
    public static let weekdaysOnly: DaysOfWeekActive = [.monday, .tuesday, .wednesday, .thursday, .friday]
    
    public static let allDays: DaysOfWeekActive = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
}

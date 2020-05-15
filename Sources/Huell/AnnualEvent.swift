//
//  AnnualEvent.swift
//  Sol
//
//  Created by Zane Whitney on 1/28/20.
//  Copyright © 2020 Kitsch. All rights reserved.
//

import Foundation

enum AnnualEvent {
    case springEquinox
    case summerSolstice
    case fallEquinox
    
    static var components = DateComponents()
    static let calendar = Calendar.current
    
    static func approximateSpringEquinox(forDate date: Date) -> Date {
        components.year = calendar.component(.year, from: date)
        components.month = 3
        components.day = 19
        
        return calendar.date(from: components)!
    }
    
    static func approximateSummerSolstice(forDate date: Date) -> Date {
        components.year = calendar.component(.year, from: date)
        components.month = 6
        components.day = 20
        
        return calendar.date(from: components)!
    }
    
    static func approximateFallEquinox(forDate date: Date) -> Date {
        components.year = calendar.component(.year, from: date)
        components.month = 9
        components.day = 23
        
        return calendar.date(from: components)!
    }
    
    static func startDate(forAnnualEvent annualEvent: AnnualEvent, forYearContainingDate date: Date) -> Date {
        switch annualEvent {
            case .springEquinox:
                return approximateSpringEquinox(forDate: date)
            case .summerSolstice:
                return approximateSummerSolstice(forDate: date)
            case .fallEquinox:
                return approximateFallEquinox(forDate: date)
        }
    }
    
    static func annualEvent(forDate date: Date) -> AnnualEvent {
        if date.isBetween(startDate(forAnnualEvent: .springEquinox, forYearContainingDate: date), and: startDate(forAnnualEvent: .summerSolstice, forYearContainingDate: date)) {
            return .springEquinox
        } else if date.isBetween(startDate(forAnnualEvent: .summerSolstice, forYearContainingDate: date), and: startDate(forAnnualEvent: .fallEquinox, forYearContainingDate: date)) {
            return .summerSolstice
        } else {
            return .fallEquinox
        }
    }
}

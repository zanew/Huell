//
//  CircadianManager.swift
//  Sol
//
//  Created by Zane Whitney on 5/2/19.
//  Copyright © 2019 Kitsch. All rights reserved.
//

import UIKit
import CoreLocation

protocol CircadianCalculator {
    static var sunriseAndSetDurationInMilliseconds: Int { get }
    static var sunriseAndSetDurationInSeconds: TimeInterval { get }
    static func nextRelevantSolarEvent(forSolarTime solarTime: SolarTime) -> SolarTime
    static func timeToNextRelevantSolarEvent(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> TimeInterval
    static func upcomingSunrise(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date
    static func upcomingSunriseEnd(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date
    static func upcomingMorning(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date
    static func upcomingSolarNoon(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date
    static func upcomingHalfSet(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date
    static func upcomingSunset(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date
    static func upcomingSunsetEnd(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date
}

public class CircadianManager {
}

extension CircadianManager: CircadianCalculator {
    static func timeToNextAnnualEvent(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> TimeInterval {
        let annualEvent = AnnualEvent.annualEvent(forDate: date)
        let nextEvent = nextRelevantAnnualEvent(forPreviousAnnualEvent: annualEvent)
        let nextEventDate = AnnualEvent.startDate(forAnnualEvent: nextEvent, forYearContainingDate: date)
        
        if #available(iOS 13.0, *) {
            return date.distance(to: nextEventDate)
        } else {
            // Fallback on earlier versions
            return nextEventDate.timeIntervalSince(date)
        }
    }
    
    static func nextRelevantAnnualEvent(forPreviousAnnualEvent annualEvent: AnnualEvent) -> AnnualEvent {
        switch annualEvent {
            case .springEquinox:
                return .summerSolstice
            case .summerSolstice:
                return .fallEquinox
            case .fallEquinox:
                return .springEquinox
        }
    }
    
    static func timeToNextRelevantSolarEvent(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> TimeInterval {
        let relativeDate = date.relative(toTimeZone: timeZone)
        let solarTime = SolarTime.solarTime(forDate: date, relativeToTimeZone: timeZone)
        let nextRelevantEvent = nextRelevantSolarEvent(forSolarTime: solarTime)
        
        let upcomingSunriseDate = upcomingSunrise(forDate: date, relativeToTimeZone: timeZone)
        let upcomingSolarNoonDate = upcomingSolarNoon(forDate: date, relativeToTimeZone: timeZone)
        let upcomingSunsetDate = upcomingSunset(forDate: date, relativeToTimeZone: timeZone)
        
        if nextRelevantEvent == .sunrise {
            if #available(iOS 13.0, *) {
                return relativeDate.distance(to: upcomingSunriseDate)
            } else {
                // Fallback on earlier versions
                return upcomingSunriseDate.timeIntervalSince(relativeDate)
            }
        } else if nextRelevantEvent == .solarNoon {
            if #available(iOS 13.0, *) {
                return relativeDate.distance(to: upcomingSolarNoonDate)
            } else {
                // Fallback on earlier versions
                return upcomingSolarNoonDate.timeIntervalSince(relativeDate)
            }
        } else {
            // sunset
            if #available(iOS 13.0, *) {
                return relativeDate.distance(to: upcomingSunsetDate)
            } else {
                // Fallback on earlier versions
                return upcomingSunsetDate.timeIntervalSince(relativeDate)
            }
        }
    }
    
    static func nextRelevantSolarEvent(forSolarTime solarTime: SolarTime) -> SolarTime {
        switch (solarTime) {
            case .sunrise:
                return .solarNoon
            case .morning:
                return .solarNoon
            case .solarNoon:
                return .sunset
            case .afternoon:
                return .sunset
            case .sunset:
                return .sunrise
            case .night:
                return .sunrise
        }
    }
    
    public static var sunriseAndSetDurationInMilliseconds: Int {
        let thirtyMinutesInMs = 1000 * 60 * 30
        return thirtyMinutesInMs
    }
    
    public static var sunriseAndSetDurationInSeconds: TimeInterval {
        return TimeInterval(sunriseAndSetDurationInMilliseconds / 1000)
    }
    
    // returns a date corresponding to the Wednesday of the week containing the
    // given date at the same time of the provided date
    fileprivate static func wednesday(ofWeekContainingDate date: Date) -> Date {
        let weekday = Calendar.current.component(.weekday, from: date)
        let wednesday = 4
        let daysAheadOrBehind = wednesday - weekday
        
        return Calendar.current.date(byAdding: .day, value: daysAheadOrBehind, to: date)!
    }
    
    // MARK: Date of average solar event in the week which contains the provided
    // date
    static func averageSunriseStartDate(forWeekContainingDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        // use wednesday as the average time
        let thisTimeWednesday = wednesday(ofWeekContainingDate: date)
        
        let wednesdaysSunrise = sunriseDate(forDayContainingDate: thisTimeWednesday, relativeToTimeZone: TimeZone.current)
        
        return wednesdaysSunrise
    }
    
    static func averageMorningDate(forWeekContainingDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        let thisTimeWednesday = wednesday(ofWeekContainingDate: date)
        
        let wednesdaysMorning = morningDate(forDayContainingDate: thisTimeWednesday, relativeToTimeZone: TimeZone.current)
        
        return wednesdaysMorning
    }
    
    static func averageSolarNoonDate(forWeekContainingDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        let thisTimeWednesday = wednesday(ofWeekContainingDate: date)
        
        let wednesdaysSolarNoon = solarNoonDate(forDayContainingDate: thisTimeWednesday, relativeToTimeZone: TimeZone.current)
        
        return wednesdaysSolarNoon
    }
    
    static func averageHalfSetDate(forWeekContainingDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        let thisTimeWednesday = wednesday(ofWeekContainingDate: date)
        
        let wednesdaysHalfSetDate = halfSetDate(forDayContainingDate: thisTimeWednesday, relativeToTimeZone: TimeZone.current)
        
        return wednesdaysHalfSetDate
    }
    
    static func averageSunsetDate(forWeekContainingDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        let thisTimeWednesday = wednesday(ofWeekContainingDate: date)
        
        let wednesdaysSunsetDate = sunsetDate(forDayContainingDate: thisTimeWednesday, relativeToTimeZone: TimeZone.current)
        
        return wednesdaysSunsetDate
    }
    
    // MARK: Solar event in the day which contains the provided date
    static func sunriseDate(forDayContainingDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        return sunriseDate(forCoordinate: Constants.bostonLoc, andDayContainingDate: date, relativeToTimeZone: timeZone)
    }
    
    static func sunsetDate(forDayContainingDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        return sunsetDate(forCoordinate: Constants.bostonLoc, andDayContainingDate: date, relativeToTimeZone: timeZone)
    }
    
    static func solarNoonDate(forDayContainingDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        return solarNoonDate(forCoordinate: Constants.bostonLoc, andDayContainingDate: date, relativeToTimeZone: timeZone)
    }
    
    static func morningDate(forDayContainingDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        return morningDate(forCoordinate: Constants.bostonLoc /*FIXME: debug*/, andDayContainingDate: date, relativeToTimeZone: timeZone)
    }
    
    static func halfSetDate(forDayContainingDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        return halfSetDate(forCoordinate: Constants.bostonLoc, andDayContainingDate: date, relativeToTimeZone: timeZone)
    }
    
    fileprivate static func sunriseDate(forCoordinate coordinate: CLLocationCoordinate2D, andDayContainingDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        // Phillips Hue doesn't support Zulu time formatting so we must change
        // the actual date itself.
        let solar = Solar.init(for: date, coordinate: coordinate)!
        // will not work for our icelandic users in winter
        let sunriseDate = solar.sunrise!.relative(toTimeZone: timeZone)
        
        return sunriseDate
    }
    
    fileprivate static func sunsetDate(forCoordinate coordinate: CLLocationCoordinate2D, andDayContainingDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        let solar = Solar.init(for: date, coordinate: coordinate)!
        // will not work for our icelandic users in winter
        let sunsetDate = solar.sunset!.relative(toTimeZone: timeZone)
        
        return sunsetDate
    }
    
    fileprivate static func solarNoonDate(forCoordinate coordinate: CLLocationCoordinate2D, andDayContainingDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        let riseDate = sunriseDate(forCoordinate: coordinate, andDayContainingDate: date, relativeToTimeZone: timeZone)
        let setDate = sunsetDate(forCoordinate: coordinate, andDayContainingDate: date, relativeToTimeZone: timeZone)
        
        return riseDate.dateBetween(otherDate: setDate)
    }
    
    fileprivate static func morningDate(forCoordinate coordinate: CLLocationCoordinate2D, andDayContainingDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        let riseDate = sunriseDate(forCoordinate: coordinate, andDayContainingDate: date, relativeToTimeZone: timeZone)
        let snDate = solarNoonDate(forCoordinate: coordinate, andDayContainingDate: date, relativeToTimeZone: timeZone)
        
        return riseDate.dateBetween(otherDate: snDate)
    }
    
    fileprivate static func halfSetDate(forCoordinate coordinate: CLLocationCoordinate2D, andDayContainingDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        let snDate = solarNoonDate(forCoordinate: coordinate, andDayContainingDate: date, relativeToTimeZone: timeZone)
        let setDate = sunsetDate(forCoordinate: coordinate, andDayContainingDate: date, relativeToTimeZone: timeZone)
        
        return snDate.dateBetween(otherDate: setDate)
    }
    
    // MARK: Next solar event based on provided date
    fileprivate static func upcomingSolarEvent(forDate date: Date, eventTimeCalculator: ((Date, TimeZone) -> Date), relativeToTimeZone timeZone: TimeZone) -> Date {
        // make it so that relative date is transparent to these calculation functions
        let sameTimeTommorrow = date.dayAfter
        let todaysEvent = eventTimeCalculator(date, timeZone)
        let tomorrowsEvent = eventTimeCalculator(sameTimeTommorrow, timeZone)
        
        let relativeDate = date.relative(toTimeZone: timeZone)

        if relativeDate > todaysEvent {
            return tomorrowsEvent
        } else {
            return todaysEvent
        }
    }
    
    static func upcomingSunrise(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        return upcomingSolarEvent(forDate: date, eventTimeCalculator: sunriseDate(forDayContainingDate:relativeToTimeZone:), relativeToTimeZone: timeZone)
    }
    
    static func upcomingSunriseEnd(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        return upcomingSolarEvent(forDate: date, eventTimeCalculator: sunriseDate(forDayContainingDate:relativeToTimeZone:), relativeToTimeZone: timeZone).addingTimeInterval(sunriseAndSetDurationInSeconds)
    }
    
    static func upcomingMorning(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        return upcomingSunrise(forDate: date, relativeToTimeZone: timeZone).dateBetween(otherDate: upcomingSolarNoon(forDate: date, relativeToTimeZone: timeZone))
    }
    
    static func upcomingSolarNoon(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        return upcomingSolarEvent(forDate: date, eventTimeCalculator: solarNoonDate(forDayContainingDate:relativeToTimeZone:), relativeToTimeZone: timeZone)
    }
    
    static func upcomingHalfSet(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        return upcomingSolarNoon(forDate: date, relativeToTimeZone: timeZone).dateBetween(otherDate: upcomingSunset(forDate: date, relativeToTimeZone: timeZone))
    }
    
    static func upcomingSunset(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        return upcomingSolarEvent(forDate: date, eventTimeCalculator: sunsetDate(forDayContainingDate:relativeToTimeZone:), relativeToTimeZone: timeZone)
    }
    
    static func upcomingSunsetEnd(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> Date {
        return upcomingSunset(forDate: date, relativeToTimeZone: timeZone).addingTimeInterval(sunriseAndSetDurationInSeconds)
    }
}

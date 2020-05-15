//
//  SolarTime.swift
//  Sol
//
//  Created by Zane Whitney on 1/28/20.
//  Copyright © 2020 Kitsch. All rights reserved.
//

import Foundation

// FIXME: debug
enum SolarTime: Int {
    case sunrise
    case morning
    case solarNoon
    case afternoon
    case sunset
    case night
    
    static func solarTime(forDate date: Date, relativeToTimeZone timeZone: TimeZone) -> SolarTime {
        let relativeDate = date.relative(toTimeZone: timeZone)

        let todaysSunriseDate = CircadianManager.sunriseDate(forDayContainingDate: date, relativeToTimeZone: timeZone)
        let todaysSunriseEndDate = todaysSunriseDate.addingTimeInterval(CircadianManager.sunriseAndSetDurationInSeconds)
        let todaysMorningDate = CircadianManager.morningDate(forDayContainingDate: date, relativeToTimeZone: timeZone)
        let todaysSolarNoonDate = CircadianManager.solarNoonDate(forDayContainingDate: date, relativeToTimeZone: timeZone)
        let todaysSunsetDate = CircadianManager.sunsetDate(forDayContainingDate: date, relativeToTimeZone: timeZone)
        let todaysSunsetEndDate = todaysSunsetDate.addingTimeInterval(CircadianManager.sunriseAndSetDurationInSeconds)
        let todaysHalfSetDate = CircadianManager.halfSetDate(forDayContainingDate: date, relativeToTimeZone: timeZone)

        if relativeDate.isBetween(todaysSunriseDate, and: todaysSunriseEndDate) {
            return .sunrise
        } else if relativeDate.isBetween(todaysSunriseDate, and: todaysSolarNoonDate.addingTimeInterval(-1)) {
            return .morning
        } else if relativeDate.isBetween(todaysMorningDate, and: todaysHalfSetDate) {
            print(todaysHalfSetDate)
            return .solarNoon
        } else if relativeDate.isBetween(todaysSolarNoonDate, and: todaysSunsetDate.addingTimeInterval(-1)) {
            return .afternoon
        } else if relativeDate.isBetween(todaysSunsetDate, and: todaysSunsetEndDate) {
            return .sunset
        } else {
            return .night
        }
    }
    
    static func lightStateBody(forSolarTime solarTime: SolarTime) -> Body {
        let coolBody = Body(on: true, colorTemperature: Constants.HueAPI.MiredColorTemps.coolest, brightness: Constants.HueAPI.maxBrightness)
        let warmBody = Body(on: true, colorTemperature: Constants.HueAPI.MiredColorTemps.warmest, brightness: Constants.HueAPI.maxBrightness)
        let off = Body(on: false)
        
        switch solarTime {
            case .sunrise:
                return warmBody
            case .morning:
                return coolBody
            case .solarNoon:
                return coolBody
            case .afternoon:
                return coolBody
            case .sunset:
                return warmBody
            case .night:
                return off
        }
    }
}

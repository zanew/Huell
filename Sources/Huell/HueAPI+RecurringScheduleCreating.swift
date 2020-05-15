//
//  HueAPI+RecurringScheduleCreating.swift
//  Sol
//
//  Created by Zane Whitney on 1/28/20.
//  Copyright © 2020 Kitsch. All rights reserved.
//

import Foundation

protocol RecurringScheduleCreating {
    func recurringWeeklySunriseStartSchedule(forWeekContainingDate date: Date) -> Schedule
    func recurringWeeklyMorningSchedule(forWeekContainingDate date: Date) -> Schedule
    func recurringWeeklySolarNoonSchedule(forWeekContainingDate date: Date) -> Schedule
    func recurringWeeklyHalfSetSchedule(forWeekContainingDate date: Date) -> Schedule
    func recurringWeeklySunsetEndSchedule(forWeekContainingDate date: Date) -> Schedule
}

extension HueAPI: RecurringScheduleCreating {
    func recurringWeeklySunriseStartSchedule(forWeekContainingDate date: Date) -> Schedule {
        let date = CircadianManager.averageSunriseStartDate(forWeekContainingDate: date, relativeToTimeZone: TimeZone.current)
        return schedule(withBrightness: Constants.HueAPI.minBrightness, ct: Constants.HueAPI.MiredColorTemps.lowestPoint, date: date)
    }
    
    func recurringWeeklyMorningSchedule(forWeekContainingDate date: Date) -> Schedule {
        let date = CircadianManager.averageMorningDate(forWeekContainingDate: date, relativeToTimeZone: TimeZone.current)
        return schedule(withBrightness: Constants.HueAPI.maxBrightness, ct: Constants.HueAPI.MiredColorTemps.halfApex, date: date)
    }
    
    func recurringWeeklySolarNoonSchedule(forWeekContainingDate date: Date) -> Schedule {
        let date = CircadianManager.averageSolarNoonDate(forWeekContainingDate: date, relativeToTimeZone: TimeZone.current)
        return schedule(withBrightness: Constants.HueAPI.maxBrightness, ct: Constants.HueAPI.MiredColorTemps.solarNoon, date: date)
    }
    
    func recurringWeeklyHalfSetSchedule(forWeekContainingDate date: Date) -> Schedule {
        let date = CircadianManager.averageHalfSetDate(forWeekContainingDate: date, relativeToTimeZone: TimeZone.current)
        return schedule(withBrightness: Constants.HueAPI.maxBrightness, ct: Constants.HueAPI.MiredColorTemps.halfApex, date: date)
    }
    
    func recurringWeeklySunsetEndSchedule(forWeekContainingDate date: Date) -> Schedule {
        let date = CircadianManager.averageSunsetDate(forWeekContainingDate: date, relativeToTimeZone: TimeZone.current)
        return schedule(withBrightness: Constants.HueAPI.minBrightness, ct: Constants.HueAPI.MiredColorTemps.lowestPoint, date: date)
    }
}

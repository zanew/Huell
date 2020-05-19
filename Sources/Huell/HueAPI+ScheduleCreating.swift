//
//  HueAPI+ScheduleCreating.swift
//  Sol
//
//  Created by Zane Whitney on 1/28/20.
//  Copyright © 2020 Kitsch. All rights reserved.
//

import Foundation

protocol ScheduleCreating {
    var daysOfWeekActive: DaysOfWeekActive { get }
    var morningSchedule: Schedule { get }
    var dawnSchedule: Schedule { get }
    var middaySchedule: Schedule { get }
    var eveningSchedule: Schedule { get }
    var sunsetSchedule: Schedule { get }
    
    func upcomingDawnSchedule(withDate date: Date) -> Schedule
    func upcomingMorningSchedule(withDate date: Date) -> Schedule
    func upcomingMiddaySchedule(withDate date: Date) -> Schedule
    func upcomingSunsetSchedule(withDate date: Date) -> Schedule
    func upcomingEveningSchedule(withDate date: Date) -> Schedule
}

// MARK: dimming and brightening schedule POST strings
extension HueAPI: ScheduleCreating {
    var daysOfWeekActive: DaysOfWeekActive {
        get {
            HueAPI.sharedInstance.activeDays
        }
        
        set {
            HueAPI.sharedInstance.activeDays = newValue
        }
    }
    
    func schedule(withBrightness brightness: Int, hue: Int, date: Date, on: Bool = true) -> Schedule {
        let body = Body(on: true, brightness: brightness, hue: hue)
        let command = Command(address: allDevicesActionEndpoint, method: .PUT, body: body)
        return Schedule(name: Constants.ScheduleDescriptions.dawnName, description: Constants.ScheduleDescriptions.dawnMorningDescription, command: command, localTime: date)
    }
    
    func schedule(withBrightness brightness: Int, ct: Int, date: Date, on: Bool = true) -> Schedule {
        let body = Body(on: true, colorTemperature: ct, brightness: brightness)
        let command = Command(address: allDevicesActionEndpoint, method: .PUT, body: body)
        return Schedule(name: Constants.ScheduleDescriptions.genericName, description: Constants.ScheduleDescriptions.genericDescription, command: command, localTime: date)
    }
    
    func postStrings(fromSchedules schedules: [Schedule]) throws -> [String] {
        let stringList = try schedules.map(postString(fromSchedule:))
        let weekdayList = stringList.map(insertAPIWeekdayFlagStrings(intoPostString:))
        return weekdayList
    }
    
    func insertAPIWeekdayFlagStrings(intoPostString string: String) -> String {
        insertAPIWeekdayFlagStrings(intoPostString: string, weekdayIntegerFlag: HueAPI.sharedInstance.daysOfWeekActive.rawValue)
    }
    
    func insertAPIWeekdayFlagStrings(intoPostString string: String, weekdayIntegerFlag: UInt) -> String {
        if let timestringPrepender = try? NSRegularExpression(pattern: "T[0-9]{2}:", options: []) {
            let fullRange = NSRange(location: 0, length: string.count)
            let doubleZeroFormatter = NumberFormatter()
            doubleZeroFormatter.minimumIntegerDigits = 3
            let substitutionTemplate = "W\(doubleZeroFormatter.string(from: NSNumber(value: weekdayIntegerFlag))!)/$0"
            
            let substitutedString = timestringPrepender.stringByReplacingMatches(in: string, options: [], range: fullRange, withTemplate: substitutionTemplate)
            
            return substitutedString
        }
        
        return string
    }
    
    func postString(fromSchedule schedule: Schedule) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(hueRFC3339Formatter)
        
        let data = try encoder.encode(schedule)
        let string = String(data: data, encoding: .utf8)!
        
        var weekDayInt: UInt = 0
        let defaultsValue = HueAPI.sharedInstance.daysOfWeekActive.rawValue
        if defaultsValue == 0 {
            weekDayInt = Constants.SettingsDefaults.daysOfWeekActive.rawValue
        } else {
            weekDayInt = defaultsValue
        }
        
        let weekdayFlagString = HueAPI.sharedInstance.insertAPIWeekdayFlagStrings(intoPostString: string, weekdayIntegerFlag: weekDayInt)
        
        return weekdayFlagString
    }
    
    func createFutureSchedules(daysAhead numDays: Int) -> [Schedule] {
        var scheduleList: [Schedule] = []
        
        var i = 0
        let date = Date()
        
        while i < numDays {
            let dawnSchedule = upcomingDawnSchedule(withDate: date.daysAfter(i))
            let morningSchedule = upcomingMorningSchedule(withDate: date.daysAfter(i))
            let middaySchedule = upcomingMiddaySchedule(withDate: date.daysAfter(i))
            let sunsetSchedule = upcomingSunsetSchedule(withDate: date.daysAfter(i))
            let eveningSchedule = upcomingEveningSchedule(withDate: date.daysAfter(i))
            
            scheduleList.append(dawnSchedule)
            scheduleList.append(morningSchedule)
            scheduleList.append(middaySchedule)
            scheduleList.append(eveningSchedule)
            scheduleList.append(sunsetSchedule)
            
            i += 1
        }
                
        return scheduleList
    }
    
    func upcomingDawnSchedule(withDate date: Date) -> Schedule {
        let body = Body(on: true, brightness: Constants.HueAPI.minBrightness, hue: Constants.HueAPI.warmestHue)
        let command = Command(address: allDevicesActionEndpoint, method: .PUT, body: body)
        let sunriseDate = CircadianManager.upcomingSunrise(forDate: date, relativeToTimeZone: TimeZone.current)
        return Schedule(name: Constants.ScheduleDescriptions.dawnName, description: Constants.ScheduleDescriptions.dawnMorningDescription, command: command, localTime: sunriseDate)
    }
    
    var dawnSchedule: Schedule {
        let now = Date()
        return upcomingDawnSchedule(withDate: now)
    }
    
    func upcomingMorningSchedule(withDate date: Date) -> Schedule {
        let body = Body(on: true, transitionTime: CircadianManager.sunriseAndSetDurationInMilliseconds, brightness: Constants.HueAPI.maxBrightness, hue: Constants.HueAPI.coolestHue)
        let command = Command(address: allDevicesActionEndpoint, method: .PUT, body: body)
        let morningDate = CircadianManager.upcomingSunriseEnd(forDate: date, relativeToTimeZone: TimeZone.current)
        return Schedule(name: Constants.ScheduleDescriptions.morningName, description: Constants.ScheduleDescriptions.dawnMorningDescription, command: command, localTime: morningDate)
    }
    
    var morningSchedule: Schedule {
        let now = Date()
        return upcomingMorningSchedule(withDate: now)
    }
    
    func upcomingMiddaySchedule(withDate date: Date) -> Schedule {
        let body = Body(on: true, brightness: Constants.HueAPI.maxBrightness, hue: Constants.HueAPI.coolestHue)
        let command = Command(address: allDevicesActionEndpoint, method: .PUT, body: body)
        let middayDate = CircadianManager.upcomingSolarNoon(forDate: date, relativeToTimeZone: TimeZone.current)
        return Schedule(name: Constants.ScheduleDescriptions.middayName, description: Constants.ScheduleDescriptions.middayDescription, command: command, localTime: middayDate)
    }
    
    var middaySchedule: Schedule {
        let now = Date()
        return upcomingMorningSchedule(withDate: now)
    }
    
    func upcomingSunsetSchedule(withDate date: Date) -> Schedule {
        let body = Body(on: true, transitionTime: CircadianManager.sunriseAndSetDurationInMilliseconds, brightness: Constants.HueAPI.minBrightness, hue: Constants.HueAPI.warmestHue)
        let command = Command(address: allDevicesActionEndpoint, method: .PUT, body: body)
        let sunsetDate = CircadianManager.upcomingSunset(forDate: date, relativeToTimeZone: TimeZone.current)
        
        return Schedule(name: Constants.ScheduleDescriptions.eveningName, description: Constants.ScheduleDescriptions.eveningDescription, command: command, localTime: sunsetDate)
    }
    
    var sunsetSchedule: Schedule {
        let now = Date()
        return upcomingSunsetSchedule(withDate: now)
    }
    
    func upcomingEveningSchedule(withDate date: Date) -> Schedule {
        let body = Body(on: false)
        let command = Command(address: allDevicesActionEndpoint, method: .PUT, body: body)
        let sunsetDate = CircadianManager.upcomingSunsetEnd(forDate: date, relativeToTimeZone: TimeZone.current)
        
        return Schedule(name: Constants.ScheduleDescriptions.eveningName, description: Constants.ScheduleDescriptions.eveningDescription, command: command, localTime: sunsetDate)
    }
    
    var eveningSchedule: Schedule {
        let now = Date()
        return upcomingEveningSchedule(withDate: now)
    }
}


//
//  HueAPI+TestScheduleCreating.swift
//  Sol
//
//  Created by Zane Whitney on 1/28/20.
//  Copyright © 2020 Kitsch. All rights reserved.
//

import Foundation

protocol TestScheduleCreating {
    var testDawnSchedule: Schedule { get }
    var testMorningSchedule: Schedule { get }
    var testMiddaySchedule: Schedule { get }
    var testSunsetSchedule: Schedule { get }
    var testEveningSchedule: Schedule { get }
    
//    func testDawnSchedule(withDate date: Date) -> Schedule
//    func testMorningSchedule(withDate date: Date) -> Schedule
//    func testMiddaySchedule(withDate date: Date) -> Schedule
//    func testSunsetSchedule(withDate date: Date) -> Schedule
//    func testEveningSchedule(withDate date: Date) -> Schedule
}

// MARK: Test schedules
extension HueAPI: TestScheduleCreating {
    var testDawnSchedule: Schedule {
        let tenSecondsFromNow = Date().addingTimeInterval(10).relative(toTimeZone: TimeZone.current)
        return schedule(withBrightness: Constants.HueAPI.minBrightness, hue: Constants.HueAPI.warmestHue, date: tenSecondsFromNow)
    }
    
    var testMorningSchedule: Schedule {
        let fifteenSecondsFromNow = Date().addingTimeInterval(15).relative(toTimeZone: TimeZone.current)
        return schedule(withBrightness: Constants.HueAPI.maxBrightness, hue: Constants.HueAPI.coolestHue, date: fifteenSecondsFromNow)
    }
    
    var testMiddaySchedule: Schedule {
        let twentySecondsFromNow = Date().addingTimeInterval(20).relative(toTimeZone: TimeZone.current)
        return schedule(withBrightness: Constants.HueAPI.maxBrightness, hue: Constants.HueAPI.coolestHue, date: twentySecondsFromNow)
    }
    
    var testSunsetSchedule: Schedule {
        let twentyFiveSecondsFromNow = Date().addingTimeInterval(25).relative(toTimeZone: TimeZone.current)
        return schedule(withBrightness: Constants.HueAPI.minBrightness, hue: Constants.HueAPI.warmestHue, date: twentyFiveSecondsFromNow)
    }
    
    var testEveningSchedule: Schedule {
        let thirtySecondsFromNow = Date().addingTimeInterval(30).relative(toTimeZone: TimeZone.current)
        return schedule(withBrightness: Constants.HueAPI.minBrightness, hue: Constants.HueAPI.warmestHue, date: thirtySecondsFromNow, on: false)
    }
}

//
//  Constants.swift
//  Sol
//
//  Created by Zane Whitney on 5/2/19.
//  Copyright © 2019 Kitsch. All rights reserved.
//

import UIKit
import CoreLocation

public class Constants {
    static let numDaysScheduledAhead = 7
    
    public enum HueAPI {
        enum MiredColorTemps {
            static let coolest = 153
            static let warmest = 500
            
            static let lowestPoint = 417 // ~2400 K
            static let halfApex = 204 // 4900 K
            static let solarNoon = 189 // ~5300 K
        }
        
        static let maxBrightness = 254
        static let minBrightness = 1
        static let maxSaturation = 254
        static let redHue = 0
        static let warmestHue = 4000
        static let coolestHue = 11500
        
        enum GroupSetResponseKeys {
            static let on = "/groups/0/action/on"
            static let brightness = "/groups/0/action/bri"
            static let hue = "/groups/0/action/hue"
            static let saturation = "/groups/0/action/sat"
        }
    }
    
    // FIXME: debug
    static let username = "Sol App"
    static let deviceType = "Test"
    static let currentBridgeIP = "192.168.1.211"
    static let authToken = "authToken"
    static let emulatedIP = "localhost"
    
    // MARK: test region
    static let bostonLat: CLLocationDegrees = 42.357536
    static let bostonLon: CLLocationDegrees = -71.057498
    static let bostonLoc = CLLocationCoordinate2DMake(bostonLat, bostonLon)
    static let bostonHomeRadiusInMeters: CLLocationDistance = 10
    static let bostonHomeRegionId = "bostonHomeRegionId"
    static let emulatedAuthToken = "newdeveloper"
    
    fileprivate static func makeBostonCircularRegion() -> CLCircularRegion {
        let region = CLCircularRegion.init(center: bostonLoc, radius: bostonHomeRadiusInMeters, identifier: bostonHomeRegionId)
        
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        return region
    }
    
    static let bostonHomeCircularRegion = makeBostonCircularRegion()
    
    static var oneWeekFromNowAt3am: Date? {
        if let threeAmToday = Calendar.current.date(bySettingHour: 3, minute: 0, second: 0, of: Date()) {
            return threeAmToday.daysAfter(7)
        } else {
            return nil
        }
    }
    
    // FIXME: Debug
    static var thirtyMinutesFromNow: Date? {
        let now = Date()
        return Calendar.current.date(byAdding: .minute, value: 30, to: now)
    }
    
    static let threeDaysInSeconds: TimeInterval = 259200
    
    enum AnimationDurations {
        static let standard = 1.0
    }
    
    enum Misc {
        static let version = "1.0.0"
        static let copyright = "Copyright © 2019-present Zane Whitney. All rights reserved."
    }
    
    enum AnnualEvents {
        static let approximateFallEquinoxDate: Date = Date()
    }
    
    enum UserDefaultsKeys {
        static let currentBridgeIP = "currentBridgeIP"
        // TODO: put in keychain
        static let apiUsername = "apiUsername"
        static let respectsDSTKey = "respectsDSTKey"
        static let hasLaunchedKey = "hasLaunchedKey"
        
        // MARK: settings
        static let enabledKey = "enableKey"
        static let hasSetupBridge = "hasSetupBridge"
        static let dawnEnabledKey = "dawnEnabled"
        static let sunriseEnabledKey = "sunriseEnabledKey"
        static let middayEnabledKey = "middayEnabledKey"
        static let sunsetEnabledKey = "sunsetEnabledKey"
        static let snoozeSunriseKey = "snoozeSunriseKey"
        static let isSnoozedKey = "isSnoozedKey"
        static let disableWhenLeavingKey = "disableWhenLeavingKey"
        static let nightlightKey = "nightlightKey"
        static let currentLocationLatKey = "currentLocationLatKey"
        static let currentLocationLonKey = "currentLocationLonKey"
        static let dawnBrightnessKey = "dawnBrightnessKey"
        static let dawnTempKey = "dawnTempKey"
        static let sunriseBrightnessKey = "sunriseBrightnessKey"
        static let sunriseTempKey = "sunriseTempKey"
        static let sunsetBrightnessKey = "sunsetBrightnessKey"
        static let sunsetTempKey = "sunsetTempKey"
        static let daysOfWeekActive = "weekdaysActiveKey"
    }

    enum SettingsDefaults {
        // on/off toggles
        static let enabled = true
        static let dawnEnabled = true
        static let sunriseEnabled = true
        static let middayEnabled = true
        static let sunsetEnabled = true
        static let nightlight = false
        static let hasSetupBridge = false
        
        static let snoozeUntilSunrise = false
        static let isSnoozed = false
        static let disableWhenLeaving = true
        static let darknessHours = 9
        static let dawnBrightness = Constants.HueAPI.minBrightness
        static let dawnTemp = Constants.HueAPI.MiredColorTemps.warmest
        static let sunriseBrightness = Constants.HueAPI.maxBrightness
        static let sunriseTemp = Constants.HueAPI.MiredColorTemps.coolest
        static let sunsetBrightness = Constants.HueAPI.minBrightness
        static let sunsetTemp = Constants.HueAPI.MiredColorTemps.warmest
        static let daysOfWeekActive = DaysOfWeekActive.weekdaysOnly
    }
    
    enum ScheduleDescriptions {
        static let genericName = "Simulated Schedule (Sol)"
        static let genericDescription = "Schedule my Hue lights to mimic the sun."
        static let dawnName = "Simulated Dawn (Sol)"
        static let dawnMorningDescription = "Brighten my hue lights in the morning to mimic the sun rising."
        static let middayDescription = "Brighten my hue lights at midday to mimic solar noon."
        static let morningName = "Simulated Morning (Sol)"
        static let middayName = "Simulated Midday (Sol)"
        static let eveningName = "Simulated Sunset (Sol)"
        static let eveningDescription = "Dim my hue lights in the evening to mimic the sun setting."
    }
}

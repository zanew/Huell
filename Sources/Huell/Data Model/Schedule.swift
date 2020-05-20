//
//  Schedule.swift
//  Sol
//
//  Created by Zane Whitney on 5/2/19.
//  Copyright © 2019 Kitsch. All rights reserved.
//

import UIKit

public struct Schedule: Codable {
    public let name: String
    public let description: String
    public let command: Command
    public let localTime: Date
    
    public enum CodingKeys: String, CodingKey {
        case name
        case description
        case command
        case localTime = "localtime"
    }
}

public struct Command: Codable {
    public let address: String
    public let method: Method
    public let body: Body
}

public enum Method: String, Codable {
    case PUT
    case POST
    case GET
    case DELETE
}

public struct Body: Codable, Equatable {
    public let on: Bool?
    public let colorTemperature: Int?
    // in milliseconds
    public let transitionTime: Int?
    public let brightness: Int?
    public let hue: Int?
    public let saturation: Int?
    
    public init(on: Bool? = nil, colorTemperature: Int? = nil, transitionTime: Int? = nil, brightness: Int? = nil, hue: Int? = nil, saturation: Int? = nil) {
        self.on = on
        self.colorTemperature = colorTemperature
        self.transitionTime = transitionTime
        self.brightness = brightness
        self.hue = hue
        self.saturation = saturation
    }
    
    public enum CodingKeys: String, CodingKey {
        case on
        case hue
        case colorTemperature = "ct"
        case transitionTime = "transitiontime"
        case brightness = "bri"
        case saturation = "sat"
    }
}

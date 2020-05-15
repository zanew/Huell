//
//  Schedule.swift
//  Sol
//
//  Created by Zane Whitney on 5/2/19.
//  Copyright © 2019 Kitsch. All rights reserved.
//

import UIKit

struct Schedule: Codable {
    let name: String
    let description: String
    let command: Command
    let localTime: Date
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case command
        case localTime = "localtime"
    }
}

struct Command: Codable {
    let address: String
    let method: Method
    let body: Body
}

enum Method: String, Codable {
    case PUT
    case POST
    case GET
    case DELETE
}

struct Body: Codable, Equatable {
    let on: Bool?
    let colorTemperature: Int?
    // in milliseconds
    let transitionTime: Int?
    let brightness: Int?
    let hue: Int?
    let saturation: Int?
    
    init(on: Bool? = nil, colorTemperature: Int? = nil, transitionTime: Int? = nil, brightness: Int? = nil, hue: Int? = nil, saturation: Int? = nil) {
        self.on = on
        self.colorTemperature = colorTemperature
        self.transitionTime = transitionTime
        self.brightness = brightness
        self.hue = hue
        self.saturation = saturation
    }
    
    enum CodingKeys: String, CodingKey {
        case on
        case hue
        case colorTemperature = "ct"
        case transitionTime = "transitiontime"
        case brightness = "bri"
        case saturation = "sat"
    }
}

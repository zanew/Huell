//
//  Response.swift
//  Sol
//
//  Created by Zane Whitney on 8/15/19.
//  Copyright © 2019 Kitsch. All rights reserved.
//

import Foundation
import Siesta

struct GroupResponse: Codable {
    let success: [String: BoolOrInt]?
    
    var successState: BoolOrInt? {
        success?.first?.value
    }
}

class GroupResponseStatuses {
    var brightnessResponseStatus: Int?
    var hueResponseStatus: Int?
    var onResponseStatus: Bool?
    var satResponseStatus: Int?
    
    init?(groupResponseArray: [GroupResponse]) {
        groupResponseArray.forEach {
            let success = $0.success
            if let responseTypeKey = success?.keys.first {
                switch (responseTypeKey) {
                    // 
                case Constants.HueAPI.GroupSetResponseKeys.brightness:
                    let value = success?[responseTypeKey]?.intValue()
                    brightnessResponseStatus = value
                case Constants.HueAPI.GroupSetResponseKeys.hue:
                    let value = success?[responseTypeKey]?.intValue()
                    hueResponseStatus = value
                case Constants.HueAPI.GroupSetResponseKeys.saturation:
                    let value = success?[responseTypeKey]?.intValue()
                    satResponseStatus = value
                case Constants.HueAPI.GroupSetResponseKeys.on:
                    let value = success?[responseTypeKey]?.boolValue()
                    onResponseStatus = value
                default:
                    break
                }
            }
        }
    }
    
    convenience init?(entity: Entity<Any>) {
        if let responseArray = entity.content as? [GroupResponse] {
            self.init(groupResponseArray: responseArray)
        } else {
            return nil
        }
    }
}

//
//  HueAPI+LightStateModifying.swift
//  Sol
//
//  Created by Zane Whitney on 1/28/20.
//  Copyright © 2020 Kitsch. All rights reserved.
//

import Foundation
import Siesta

// MARK: PUTting State
extension HueAPI {
    fileprivate func putAllDevices(_ body: Body) throws -> Request {
        guard let service = HueAPI.sharedInstance.service else {
            throw NetworkError.serviceNotInitialized
        }
        
        do {
            let encoder = JSONEncoder()
            let onData = try encoder.encode(body)
            let string = String(data: onData, encoding: .utf8)!
            
            return service.resource(HueAPI.sharedInstance.allDevicesActionEndpoint).request(.put, text: string)
        } catch {
            throw NetworkError.cannotEncodeModelRequest
        }
    }
    
    func putLightBody(state: Bool) throws -> Request {
        return try putAllDevices(Body(on: state))
    }
}

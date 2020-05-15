//
//  BoolOrInt.swift
//  Sol
//
//  Created by Zane Whitney on 8/20/19.
//  Copyright © 2019 Kitsch. All rights reserved.
//

import Foundation

enum BoolOrInt: Codable {
    case bool(Bool)
    case int(Int)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .bool(try container.decode(Bool.self))
        } catch DecodingError.typeMismatch {
            self = .int(try container.decode(Int.self))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let bool): try container.encode(bool)
        case .int(let int): try container.encode(int)
        }
    }
    
    func boolValue() -> Bool? {
        return get() as? Bool
    }
    
    func intValue() -> Int? {
        return get() as? Int
    }
    
    func get() -> Any {
        switch self {
        case .int(let int):
            return int
        case .bool(let bool):
            return bool
        }
    }
}

//
//  HueError.swift
//  Sol
//
//  Created by Zane Whitney on 4/30/19.
//  Copyright © 2019 Kitsch. All rights reserved.
//

import UIKit

struct ContainerError: Codable {
    let type: Int
    let address: String
    let description: String
}

struct HueError: Codable {
    // TODO: how do I just use this part of the JSON object?
    let error: ContainerError
}

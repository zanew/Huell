//
//  SuccessIfResponseDictNotErrorTransformer.swift
//  Sol
//
//  Created by Zane Whitney on 1/28/20.
//  Copyright © 2020 Kitsch. All rights reserved.
//

import Foundation
import Siesta

struct SuccessIfResponseDictNotErrorTransformer: ResponseTransformer {
    func process(_ response: Response) -> Response {
        switch response {
        case .success(let entity):
            // cause network response to fail if we parse the response JSON is a Hue API error
            if let responseArray: [HueError] = try? HueAPI.sharedInstance.jsonDecoder.decode([HueError].self, from: entity.content as! Data) {
                let hueError: HueError? = responseArray[0]
                let requestError = RequestError(userMessage: hueError?.error.description ?? "none", cause: NetworkError.hueAPIError(type: APIErrorType.init(rawValue:hueError?.error.type ?? 0)), entity: entity)
                return logTransformation(.failure(requestError))
            } else {
                return response
            }
        case .failure( _):
            return response
        }
    }
    
    fileprivate func isHueErrorResponse(jsonArr: [[AnyHashable : Any]]) -> Bool {
        if jsonArr.count > 0 {
            let firstEl = jsonArr[0]
            if firstEl["error"] as! String == "error" {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}

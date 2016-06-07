//
//  ShakerAPI.swift
//  shaker_full
//
//  Created by Andrey Egorov on 6/6/16.
//  Copyright © 2016 Andrey Egorov. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Alamofire

enum ShakerAPI {
    class Parameters {
        class var defaultParameters: [String: AnyObject] {
            get {
                 return [
                     "device_id" : "ADD6F9BF-F514-4605-9184-715C34D23443 ",
                     "random_key" : 1,
                     "crypt" : 1,
                     "time" : 1
                 ]
            }
        }
    }
    
    case Login
    
    case UserProfile
    case Feedback
}

extension ShakerAPI: TargetType {
    var base: String { return AppSetup.sharedState.useStaging ? "https://stagingapi.shakerapp.ru" : "https://api.shakerapp.ru" }
    var baseURL: NSURL { return NSURL(string: base)! }
    
    var path: String {
        switch self {
        case .Feedback:
            return "v10/feedback/activities"
        default:
            return ""
        }
    }
    
    var parameters: [String: AnyObject]? {
        return Parameters.defaultParameters
    }
    
    var method: Moya.Method {
        switch self {
        case .Feedback:
            return .GET
        default:
            return .GET
        }
    }
    
    internal func url(route: TargetType) -> String {
        return route.baseURL.URLByAppendingPathComponent(route.path).absoluteString
    }
    
    var sampleData: NSData { return NSData() }
}
//
//  AppSetup.swift
//  shaker_full
//
//  Created by Andrey Egorov on 6/6/16.
//  Copyright © 2016 Andrey Egorov. All rights reserved.
//

import UIKit

class AppSetup {
    lazy var useStaging = true
    
    class var sharedState: AppSetup {
        struct Static {
            static let instance = AppSetup()
        }
        return Static.instance
    }
    
    init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        useStaging = defaults.boolForKey("ShakerUseStaging")
    }
}

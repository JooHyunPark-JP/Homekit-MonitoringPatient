//
//  HomeStore.swift
//  HomeKit Sensor Test
//
//  Created by Xcode User on 2018-05-29.
//  Copyright © 2018 Xcode User. All rights reserved.
//

import HomeKit
import UIKit

class HomeStore : NSObject {
    
    struct Notification {
        static let AddAccessoryNotification = "AddAccessoryNotification"
    }
    
    
    static let sharedInstance = HomeStore()
    
    var homeManager: HMHomeManager = HMHomeManager()
    var home: HMHome?
}

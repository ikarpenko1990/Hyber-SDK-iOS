//
//  Device.swift
//  Pods
//
//  Created by Taras on 10/25/16.
//
//

import RealmSwift

class Device: Object {
    
    dynamic var installationId = ""
    dynamic var osType = ""
    dynamic var osVersion = ""
    dynamic var deviceType = ""
    dynamic var deviceName = ""
    dynamic var modelName = ""
    dynamic var createdAt = NSDate()
    dynamic var updatedAt = NSDate()
    let userId = User()
    
}

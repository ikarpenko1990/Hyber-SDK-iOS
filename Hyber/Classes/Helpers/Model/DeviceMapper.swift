//
//  Device.swift
//  Pods
//
//  Created by Taras on 11/10/16.
//
//

import ObjectMapper

class DeviceMapper: Mappable {

    var device: DeviceDetails?

    required init?( map: Map) {
        mapping(map: map)
    }

    func mapping(map: Map) {
        device <- map["device"]

    }
}

//MARK: DeviceInfo
class DeviceDetails: Mappable {

    var osType: String?
    var osVersion: String?
    var deviceType: String?
    var devicaName: String?
    var modelName: String?
    var createdAt: String?
    var updatedAt: String?

    required init?( map: Map) {
        mapping(map: map)
    }

    func mapping(map: Map) {
        osType <- map["osType"]
        osVersion <- map["osVersion"]
        deviceType <- map["deviceType"]
        devicaName <- map["devicaName"]
        modelName <- map["modelName"]
        createdAt <- map["createdAt"]
        updatedAt <- map["updatedAt"]
    }
}

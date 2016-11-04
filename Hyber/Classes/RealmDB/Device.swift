//
//  Device.swift
//  Pods
//
//  Created by Taras on 10/25/16.
//
//
import ObjectMapper
import RealmSwift

private func <- <T: Mappable>(left: List<T>, right: Map)
{
    var array: [T]?
    
    if right.mappingType == .toJSON
    {
        array = Array(left)
    }
    
    array <- right
    
    if right.mappingType == .fromJSON
    {
        if let theArray = array
        {
            left.append(objectsIn: theArray)
        }
    }
}


class Device: Object, Mappable {
    
    dynamic var installationId = ""
    dynamic var osType = ""
    dynamic var osVersion = ""
    dynamic var deviceType = ""
    dynamic var deviceName = ""
    dynamic var modelName = ""
    dynamic var createdAt = NSDate()
    dynamic var updatedAt = NSDate()
    let userId = User()
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        installationId <- map["installationId"]
        osType <- map["osType"]
        osVersion <- map["osVersion"]
    }
    
}

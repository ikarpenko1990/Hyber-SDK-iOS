//
//  session.swift
//  Pods
//
//  Created by Taras on 10/25/16.
//
//
import ObjectMapper
import RealmSwift

class Session: Object, Mappable {
    
    dynamic var sessionToken = ""
    dynamic var refreshToken = ""
    dynamic var expirationDate = ""
    dynamic var fcmToken = ""
    dynamic var owner: User?
    

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        sessionToken <- map["sessionToken"]
        refreshToken <- map["refreshToken"]
        expirationDate <- map["expirationDate"]
        fcmToken <- map["fcmToken"]
    }
    
}

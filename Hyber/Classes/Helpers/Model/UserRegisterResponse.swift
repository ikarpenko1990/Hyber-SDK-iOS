//
//  UserRegisterResponse.swift
//  Pods
//
//  Created by Taras on 11/9/16.
//
//
import SwiftyJSON
import ObjectMapper

internal class UserRegisterResponse: Mappable{
    
    
    var session: UserSession?
    var user: UserProfile?
 
    required  init?( map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        session       <- map["session"]
        user          <- map["profile"]
       
    }
}

internal class UserProfile: Mappable {
    var userId: String?
    var userPhone: String?

    required  init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        
        userId          <- map["userId"]
        userPhone       <- map["userPhone"]
    }
    
}

internal class UserSession: Mappable{
    var sessionToken: String?
    var refreshToken: String?
    var expirationDate: String?
    
    required  init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        
        refreshToken    <- map["refreshToken"]
        sessionToken    <- map["token"]
        expirationDate  <- map["expirationDate"]
        
    }

}


//
//  Profile.swift
//  Pods
//
//  Created by Taras on 10/25/16.
//
//
import ObjectMapper
import RealmSwift
import SwiftyJSON

class User: Object, Mappable {
    dynamic var userId  = ""
    dynamic var userPhone = ""
    dynamic var createdAt : String = ""
    
    convenience required init?(map: Map) {
        self.init()
//        userId <- map["userId"]
    }
    
    func mapping(map: Map) {
        userId <- map["userId"]
        userPhone <- map["userPhone"]
        createdAt <- map["createdAt"]
    }
 }

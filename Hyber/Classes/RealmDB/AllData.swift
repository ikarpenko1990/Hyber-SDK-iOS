//
//  AllData.swift
//  Pods
//
//  Created by Taras on 10/31/16.
//
//

import RealmSwift
import ObjectMapper
import AlamofireObjectMapper


class AllData: Object {

  dynamic var username:String?
  dynamic var session:String?
  var messages = List<Message>()
    
    convenience required init?(map: Map) {
        self.init()
        //        userId <- map["userId"]
    }
    
    func mapping(map: Map) {
        username <- map["profile"]
        session <- map["session"]
        messages <- map["message"]
    }

}

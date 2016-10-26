//
//  MessageHistory.swift
//  Pods
//
//  Created by Taras on 10/25/16.
//
//

import RealmSwift

class Message:  Object {
    
    dynamic var ownerPhone = ""
    dynamic var messageId = ""
    dynamic var title = ""
    dynamic var body = ""
    dynamic var imageUrl = ""
    dynamic var buttonCaption = ""
    dynamic var buttonAction = ""
    dynamic var time = Double()
    dynamic var partner = ""
    let userId = User()

    
}

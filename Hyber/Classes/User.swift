//
//  Profile.swift
//  Pods
//
//  Created by Taras on 10/25/16.
//
//

import RealmSwift

class User: Object {
    
    dynamic var userId = ""
    dynamic var userPhone = ""
    dynamic var createdAt = NSDate()
    
}

//
//  session.swift
//  Pods
//
//  Created by Taras on 10/25/16.
//
//

import RealmSwift

class Session: Object {
    
    dynamic var sessionToken = ""
    dynamic var refreshToken = ""
    dynamic var expirationDate = NSDate()
    dynamic var fcmToken = ""
    let userId = User()


}

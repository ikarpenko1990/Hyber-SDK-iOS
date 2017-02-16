//
//  Headers.swift
//  Pods
//
//  Created by Taras Markevych on 2/28/17.
//
//

import UIKit
import RealmSwift
class Headers: NSObject {
    
    static func getHeaders() -> [String:String] {
         let realm = try! Realm()
         let date = NSDate()
         let timestamp = UInt64(floor(date.timeIntervalSince1970 * 1000))
         let token: String? = realm.objects(Session.self).last!.mToken!
         let kUUID: String? = realm.objects(Session.self).first!.mSessionToken
         let timeString = String(timestamp)
         let shaPass = token! + ":" + timeString
         let crytped = shaPass.sha256()
        
         let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Session-Id":  "\(kUUID!)",
            "X-Hyber-Auth-Token": "\(crytped)",
            "X-Hyber-Timestamp": "\(timeString)"
         ]
        HyberLogger.debug(headers)
        return headers
    }
}

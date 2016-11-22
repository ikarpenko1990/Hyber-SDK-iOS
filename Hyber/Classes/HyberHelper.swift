//
//  HyberHelper.swift
//  Pods
//
//  Created by Taras on 11/8/16.
//
//

import UIKit
import NotificationCenter
import RxSwift
import RealmSwift

extension Hyber {

    public static func initialise(clientApiKey: String, firebaseMessagingHelper: HyberFirebaseMessagingHelper) -> Void  {
                

        let defaults = UserDefaults.standard
            if defaults.object(forKey: "clientApiKey") == nil {
                defaults.set(clientApiKey, forKey: "clientApiKey")
                defaults.synchronize()
                HyberLogger.info("Hyber SDK initialised, Client API KEY: \(clientApiKey) saved!")
            } else {
                defaults.set(clientApiKey, forKey: "clientApiKey")
                defaults.synchronize()
                HyberLogger.info("Hyber SDK initialised")
            }
        var config = Realm.Configuration()
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("Hyber.realm")
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config

    }
    
    public static func saveToken(fcmToken: String) -> Void {
        //sync fcm Token
        let defaults = UserDefaults.standard
        defaults.set(fcmToken, forKey: "fcmToken")
        defaults.synchronize()
        
    }
    
//    public func clearHistory() -> Void {
//        try! RealmData.urealm.write {
//            RealmData.urealm.delete(RealmData.urealm.objects(Message.self))
//        }
//    }
    
    public class func getMessageHistory() -> [NSArray]? {
        let realm = try! RealmData.urealm
        let objects = try! realm.objects(Message.self).toArray(ofType : NSArray.self) as [NSArray]
        
        return objects.count > 0 ? objects : nil
    }
    
}


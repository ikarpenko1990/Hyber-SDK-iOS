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
import SwiftyJSON

extension Hyber {

    public static func initialise(clientApiKey: String, firebaseMessagingHelper: HyberFirebaseMessagingHelper, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Void  {
                
        
        if launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil {
            
            // For Notification
            if let localNotificationInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as! [AnyHashable : Any]? {
                if let validJson = JSON(localNotificationInfo) as? [String:AnyObject] {
                    let fcmMsgID = validJson["gcm.message_id"] as? String
                    let messageString = validJson["message"] as? String
                    if let data = messageString?.data(using: String.Encoding.utf8) {
                        var json = JSON(data: data)
                        let hyberMsgID = json["mess_id"].rawString()
                        if hyberMsgID != nil {
                            Hyber.sentDeliveredStatus(messageId: hyberMsgID!)
                            
                        }
                    }
                }
              
            }
        }
        
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
    
    func clearHistory() -> Void {
        try! RealmData.urealm.write {
            RealmData.urealm.delete(RealmData.urealm.objects(Message.self))
        }
    }
    
}


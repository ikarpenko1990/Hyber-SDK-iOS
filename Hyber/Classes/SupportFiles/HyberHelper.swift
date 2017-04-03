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

    public static func initialise(clientApiKey: String, firebaseMessagingHelper: HyberFirebaseMessagingHelper, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Void {
        if launchOptions == nil {
            UIApplication.shared.applicationIconBadgeNumber = 0
             let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
                if userInfo != nil {
                    didReceiveRemoteNotification(userInfo: userInfo!)
                }
            } else {
            let notificationPayload: NSDictionary = launchOptions![UIApplicationLaunchOptionsKey.remoteNotification] as! NSDictionary
                didReceiveRemoteNotification(userInfo: notificationPayload as! [AnyHashable : Any])
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        
        let defaults = UserDefaults.standard
            defaults.set(clientApiKey, forKey: "clientApiKey")
            defaults.synchronize()
            HyberLogger.info("Hyber SDK initialised, Client API KEY: \(clientApiKey)!")
       
        //Realm configuration
        var config = Realm.Configuration(schemaVersion: 1,
                                         migrationBlock: { migration, oldSchemaVersion in
                                         if (oldSchemaVersion < 1) {
                                                        // Nothing to do!
                                                        // Realm will automatically detect new properties and removed properties
                                        }
        })
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("Hyber.realm")
        Realm.Configuration.defaultConfiguration = config
        updateDevice()

    }

    public static func saveToken(fcmToken: String?) -> Void {
        //sync fcm Token
        let defaults = UserDefaults.standard
            defaults.set(fcmToken, forKey: "fcmToken")
            defaults.synchronize()
        }

    public static func clearHistory(entity: Object.Type) -> Void {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(entity))
        }
    }
    
    public static func LogOut() -> Void {
        let realm = try! Realm()
           try! realm.write {
                realm.deleteAll()
            }
        HyberLogger.info("User logout")
    }
    
}


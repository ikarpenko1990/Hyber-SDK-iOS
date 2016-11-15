//
//  HyberHelper.swift
//  Pods
//
//  Created by Taras on 11/8/16.
//
//

import UIKit
import NotificationCenter

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
    }
    
    public static func saveToken(fcmToken: String) -> Void {
        //sync fcm Token
        let defaults = UserDefaults.standard
        defaults.set(fcmToken, forKey: "fcmToken")
        defaults.synchronize()
        
    }
    
    

}

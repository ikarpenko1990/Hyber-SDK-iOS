//
//  HyberPushNotification.swift
//  Pods
//
//  Created by Taras on 10/21/16.
//
//
import Foundation
import UIKit

public extension HyberPushNotification {
    
    /**
     Returns `UILocalNotification` initialized with `self`
     - Returns: New `UILocalNotification` object
     */
    public func localNotification() -> UILocalNotification {
        
        let localNotification = UILocalNotification()
        
        localNotification.timeZone = NSTimeZone.default
        localNotification.alertBody = body
        
        if #available(iOS 8.2, *) {
            localNotification.alertTitle = title
        }
        
        localNotification.alertAction = actionLocalizationKey
        localNotification.hasAction = actionLocalizationKey != .none
        
        localNotification.soundName = sound
        localNotification.applicationIconBadgeNumber = bage ?? 0
        
        localNotification.alertLaunchImage = launchImage
        
        localNotification.category = category
        
        localNotification.fireDate = NSDate() as Date
        
        return localNotification
        
    }
    
}

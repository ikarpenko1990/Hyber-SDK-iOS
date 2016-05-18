//
//  HyberPushNotification+LocalNotification.swift
//  Hyber
//
//  Created by Vitalii Budnik on 2/10/16.
//
//

import Foundation
import UIKit

/**
 Presents `HyberPushNotification` as `UILocalNotification`
 */
public extension HyberPushNotification {
  
  /**
   Returns `UILocalNotification` initialized with `self`
   - Returns: New `UILocalNotification` object
   */
  public func localNotification() -> UILocalNotification {
    
    let localNotification = UILocalNotification()
    
    localNotification.timeZone = NSTimeZone.defaultTimeZone()
    localNotification.alertBody = body
    
    if #available(iOS 8.2, *) {
      localNotification.alertTitle = title
    }
    
    localNotification.alertAction = actionLocalizationKey
    localNotification.hasAction = actionLocalizationKey != .None
    
    localNotification.soundName = sound
    localNotification.applicationIconBadgeNumber = bage ?? 0
    
    localNotification.alertLaunchImage = launchImage
    
    localNotification.category = category
    
    localNotification.fireDate = NSDate()
    
    return localNotification
    
  }
  
}

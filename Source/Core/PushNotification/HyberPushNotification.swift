//
//  Hyber+PushNotification.swift
//  Hyber
//
//  Created by Vitalii Budnik on 12/14/15.
//
//

import Foundation
import UIKit

// swiftlint:disable line_length
/**
  Apple Remote Push-notification presenter

 - SeeAlso: [The Remote Notification Payload](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/TheNotificationPayload.html)
 */
public struct HyberPushNotification {
  // swiftlint:enable line_length
  
  /**
   Stores shared `NSNumberFormatter`
   */
  static private let numberFormatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    return formatter
  }()
  
  /**
   `UInt64` Hyber message identifier
   */
  public let hyberMessageID: UInt64
  
  /**
   `String` Google Cloud Messaging message identifier
   */
  public let gcmMessageID: String?
  
  /**
   `String` representing sender. Can be `nil`
   */
  public let sender: String
  
  /**
   The number to display as the app’s icon badge.
   */
  public let bage: Int?
  
  /**
   The name of the file containing the sound to play when an alert is displayed.
   */
  public let sound: String?
  
  /**
   Provide this key with a value of `true` to indicate that new content is available. 
   Including this key and value means that when your app is launched in the background or resumed 
   `application:didReceiveRemoteNotification:fetchCompletionHandler:` is called.
   
   
   */
  public let contentAvailable: Bool
  // swiftlint:disable line_length
  /**
   Provide this key with a string value that represents the identifier property of the `UIMutableUserNotificationCategory` object you created to define custom actions. To learn more about using custom actions.
   
   - SeeAlso: [Registering Your Actionable Notification Types](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW26).
   */
  public let category: String?
  // swiftlint:enable line_length
  
  /// The text of the alert message.
  public let body: String?
  
  /** 
   A short string describing the purpose of the notification. Apple Watch displays this string as part of 
   the notification interface. This string is displayed only briefly and should be crafted so that 
   it can be understood quickly. This key was added in iOS 8.2.
   */
  public let title: String?
  
  /** 
   The key to a title string in the `Localizable.strings` file for the current localization. The key string 
   can be formatted with `%@` and `%n$@` specifiers to take the variables specified in the 
   `titleLocalizationArguments` array.
   */
  public let titleLocalizationKey: String?
  
  /**
   Variable string values to appear in place of the format specifiers in `titleLocalizationKey`.
   */
  public let titleLocalizationArguments: [String]?
  
  /**
   If a string is specified, the system displays an alert that includes the Close and View buttons. 
   The string is used as a key to get a localized string in the current localization to use 
   for the right button’s title instead of “View”.
   */
  public let actionLocalizationKey: String?
  
  /**
   A key to an alert-message string in a `Localizable.strings` file for the current localization 
   (which is set by the user’s language preference). The key string can be formatted with `%@` and `%n$@` 
   specifiers to take the variables specified in the `localizationArguments` array.
   */
  public let localizationKey: String?
  
  /**
   Variable string values to appear in place of the format specifiers in `localizationKey`
   */
  public let localizationArguments: [String]?
  
  /**
   The filename of an image file in the app bundle; it may include the extension or omit it. 
   The image is used as the launch image when users tap the action button or move the action slider. 
   If this property is not specified, the system either uses the previous snapshot,uses the image 
   identified by the `UILaunchImageFile` key in the app’s `Info.plist` file, or falls back to `Default.png`.
   */
  public let launchImage: String?
  
  /// `Bool` that indicates user allowed alert- or sound-notifications for this application is Settings
  public let notificationsAllowed: Bool
  
  /**
   Push-notification's delivered `NSDate`
   */
  public let deliveredDate: NSDate
  
  /**
   Initalizes `HyberPushNotification` with
   - Parameter withNotificationInfo: `[NSObject : AnyObject]` with modified payload, 
   where `"data"` dictionary shifted to root
   - Parameter hyberMessageID: `UInt64` Hyber message identifier
   - Parameter gcmMessageID: `String` Google Cloud Messaging message identifier. Can be `nil`
   - Parameter sender: `String` representing senders name. Can be `nil`
   - Parameter notificationsAllowed: `Bool` that indicates user allowed alert- or sound-notifications 
   for this application is Settings
   */
  private init(
    withNotificationInfo notifictionInfo: [String : AnyObject],
    hyberMessageID: UInt64,
    gcmMessageID: String?,
    sender: String,
    notificationsAllowed: Bool = true) // swiftlint:disable:this opening_brace
  {
    
    let tmpSound: String
    
    self.hyberMessageID       = hyberMessageID
    self.gcmMessageID         = gcmMessageID
    
    self.sender               = sender
    
    self.notificationsAllowed = notificationsAllowed
    
    
    tmpSound = notifictionInfo["sound"] as? String ?? UILocalNotificationDefaultSoundName
    
    contentAvailable = (notifictionInfo["content-available"] as? Int ?? 0) == 1 ? true : false
    
    category = notifictionInfo["category"] as? String
    sound    = tmpSound == "default" ? UILocalNotificationDefaultSoundName : tmpSound
    bage     = notifictionInfo["bage"] as? Int ?? 0
    
    if let alert = notifictionInfo["alert"] as? [String: AnyObject] {
      
      body                       = alert["body"] as? String
      
      title						           = alert["title"] as? String
      
      titleLocalizationKey       = alert["title-loc-key"] as? String
      titleLocalizationArguments = alert["title-loc-args"] as? [String]
      actionLocalizationKey      = alert["action-loc-key"] as? String
      localizationKey            = alert["loc-key"] as? String
      localizationArguments      = alert["loc-args"] as? [String]
      launchImage                = alert["launch-image"] as? String
      
    } else {
      
      body                       = notifictionInfo["alert"] as? String ?? notifictionInfo["body"] as? String
      
      title                      = notifictionInfo["title"] as? String
      
      titleLocalizationKey       = notifictionInfo["title-loc-key"] as? String
      titleLocalizationArguments = notifictionInfo["title-loc-args"] as? [String]
      actionLocalizationKey      = notifictionInfo["action-loc-key"] as? String
      localizationKey            = notifictionInfo["loc-key"] as? String
      localizationArguments      = notifictionInfo["loc-args"] as? [String]
      launchImage                = notifictionInfo["launch-image"] as? String
      
    }
    
    deliveredDate = NSDate()
    
  }
  
  /**
   Returns `UInt64` Hyber message identifier, stored in push-notification payload.
   Can return `0`
   - Parameter withUserInfo: `[NSObject : AnyObject]` with modified payload, where `"data"` dictionary 
   shifted to root
   - Returns: `UInt64` with Hyber message identifier. Can be `0` if key not found,
   or can't be typecasted
   */
  private static func getHyberMessageID(
    withUserInfo userInfo: [NSObject : AnyObject])
    -> UInt64  // swiftlint:disable:this opnening_brace
  {
    
    let hyberMessageID: UInt64
    if let incomeMessageID = userInfo["msg_gms_uniq_id"] {
      if let incomeMessageID = incomeMessageID as? String {
        if let incomeMessageIDFromString = HyberPushNotification.numberFormatter
          .numberFromString(incomeMessageID)?.unsignedLongLongValue {
          
          hyberMessageID = incomeMessageIDFromString
        } else {
          hyberLog.error("String incomeMessageID not convertible to UInt64")
          
          hyberMessageID = 0
        }
      } else if let incomeMessageID = incomeMessageID as? Double {
        
        hyberMessageID = UInt64(incomeMessageID)
        
      } else {
        hyberLog.error("unexpected userInfo[\"uniqAppDeviceId\"] type: \(incomeMessageID.dynamicType)")
        
        hyberMessageID = 0
      }
    } else {
      hyberMessageID = 0
    }
    
    return hyberMessageID
  }
  
  // swiftlint:disable valid_docs
  
  /**
   Initalizes `HyberPushNotification` with push-notification payload
   - Parameter withNotificationInfo: `[NSObject : AnyObject]` with modified payload, 
   where `"data"` dictionary shifted to root
   - Parameter notificationsAllowed: `Bool` that indicates user allowed alert- or sound-notifications 
   for this application is Settings
   - Returns: Initalizated `struct` if sucessfully parsed `userInfo` parameter, otherwise returns `nil`
   */
  internal init?(withUserInfo userInfo: [NSObject : AnyObject], notificationsAllowed: Bool = true) {
    // swiftlint:enable valid_docs
    
    let hyberMessageID = HyberPushNotification.getHyberMessageID(withUserInfo: userInfo)
    
    let gcmMessageID: String?
    if let _gcmMessageID = userInfo["gcm.message_id"] as? String {
      
      gcmMessageID = _gcmMessageID
      
      if hyberMessageID == 0 {
        hyberLog.debug("recieved message from GCM, that was not sended by GSM (no msg_gms_uniq_id key)")
      }
      
    } else {
      
      hyberLog.verbose("No Google, no cry")
      
      gcmMessageID = .None
      
    }
    
    guard let
      notifictionString = userInfo["notification"] as? String,
      notifictionData = notifictionString.dataUsingEncoding(NSUTF8StringEncoding),
      json = try? NSJSONSerialization.JSONObjectWithData(
        notifictionData,
        options: NSJSONReadingOptions.AllowFragments),
      notifictionInfo = json as? [String: NSObject]
      else {
        hyberLog.error("no 'notification' data ")
        return nil
    }
    
    self = HyberPushNotification(
      withNotificationInfo: notifictionInfo,
      hyberMessageID: hyberMessageID,
      gcmMessageID: gcmMessageID,
      sender: userInfo["alpha"] as? String ?? HyberDataInboxSender.unknownSenderNameString,
      notificationsAllowed: notificationsAllowed)
    
  }
}

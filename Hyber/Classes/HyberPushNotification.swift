//
//  HyberPushNotification.swift
//  Pods
//
//  Created by Taras on 10/21/16.
//
//
import Foundation
import UIKit

public struct HyberPushNotification {
    /**
     Stores shared `NSNumberFormatter`
     */
    static private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        return formatter
    }()
    
    /**
     `UInt64` Hyber message identifier
     */
    public let hyberMessageID: UInt64
    
    /**
     `String` Firebase Messaging message identifier
     */
    public var firebaseMessageID: String?
    
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
     The name of the file containing the image to display IOS 10 only
     */
    
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
     `Bool` that indicates show local notification to user, or not
     `true` - show local notification, `false` - otherwise.
     */
    internal let showLocalNotification: Bool
    
    /**
     `Bool` that indicates that this is remote notification,
     `false` if this is local notification
     */
    public let isRemoteNotification: Bool
    
    /**
     Initalizes `HyberPushNotification` with
     - Parameter withNotificationInfo: Recieved push notification payload dictionary
     - Parameter isRemoteNotification: pass `true` this is remote notification,
     `false` if this is local notification
     - Parameter hyberMessageID: `UInt64` Hyber message identifier
     - Parameter firebaseMessageID: `String` Firebase Messaging message identifier. Can be `nil`
     - Parameter sender: `String` representing senders name. Can be `nil`
     - Parameter showLocalNotification: `Bool` that indicates show local notification to user, or not
     */
    private init(
        withNotificationInfo notificationInfo: [String : AnyObject],
        isRemoteNotification: Bool,
        hyberMessageID: UInt64,
        firebaseMessageID: String?,
        sender: String,
        showLocalNotification: Bool = true)
    {
        
        let tmpSound: String
        
        self.hyberMessageID       = hyberMessageID
        self.firebaseMessageID    = firebaseMessageID
        
        self.sender               = sender
        
        self.notificationsAllowed = UIUserNotificationSettings.userNotificationsAllowed()
        
        
        tmpSound = notificationInfo["sound"] as? String ?? UILocalNotificationDefaultSoundName
        
        contentAvailable = (notificationInfo["content-available"] as? Int ?? 0) == 1 ? true : false
        
        category = notificationInfo["category"] as? String
        sound    = tmpSound == "default" ? UILocalNotificationDefaultSoundName : tmpSound
        bage     = notificationInfo["bage"] as? Int ?? 0
        
        if let alert = notificationInfo["alert"] as? [String: AnyObject] {
            
            body                       = alert["body"] as? String
            
            title						           = alert["title"] as? String
            
            titleLocalizationKey       = alert["title-loc-key"] as? String
            titleLocalizationArguments = alert["title-loc-args"] as? [String]
            actionLocalizationKey      = alert["action-loc-key"] as? String
            localizationKey            = alert["loc-key"] as? String
            localizationArguments      = alert["loc-args"] as? [String]
            launchImage                = alert["launch-image"] as? String
            
        } else {
            
            body                       = notificationInfo["alert"] as? String ?? notificationInfo["body"] as? String
            
            title                      = notificationInfo["title"] as? String
            
            titleLocalizationKey       = notificationInfo["title-loc-key"] as? String
            titleLocalizationArguments = notificationInfo["title-loc-args"] as? [String]
            actionLocalizationKey      = notificationInfo["action-loc-key"] as? String
            localizationKey            = notificationInfo["loc-key"] as? String
            localizationArguments      = notificationInfo["loc-args"] as? [String]
            launchImage                = notificationInfo["launch-image"] as? String
            
        }
        
        deliveredDate = NSDate()
        
        self.showLocalNotification = showLocalNotification
        
        self.isRemoteNotification = isRemoteNotification
        
    }
    
    /**
     Returns `UInt64` Hyber message identifier, stored in push-notification payload.
     Can return `0`
     - Parameter withUserInfo: Recieved push notification payload dictionary
     - Returns: `UInt64` with Hyber message identifier. Can be `0` if key not found,
     or can't be typecasted
     */
    
    private static func getHyberMessageID(
        withUserInfo userInfo: [NSObject : AnyObject])
        -> UInt64  // swiftlint:disable:this opnening_brace
    {
        
        let data = userInfo.jsonFor(key: "data" as NSObject)// ?? userInfo
        
        guard let incomeMessageID = data?["msg_gms_uniq_id"] else {
            print("Can't get hyberMessageID. No \"msg_gms_uniq_id\" key in userInfo[\"data\"] section")
            return 0
        }
        
        let hyberMessageID: UInt64
        
        if let incomeMessageID = incomeMessageID as? String {
            if let incomeMessageIDFromString = HyberPushNotification.numberFormatter
                .number(from: incomeMessageID)?.uint64Value {
                
                hyberMessageID = incomeMessageIDFromString
            } else {
               print("Can't get hyberMessageID. String incomeMessageID not convertible to UInt64")
                
                hyberMessageID = 0
            }
        } else if let incomeMessageID = incomeMessageID as? Double {
            
            hyberMessageID = UInt64(incomeMessageID)
            
        } else {
            print("Can't get hyberMessageID. Unexpected userInfo[\"data\"][\"msg_gms_uniq_id\"] type: \(type(of: incomeMessageID)). Expected `String` or `Double` (aka `UInt64`)")
            
            hyberMessageID = 0
        }
        
        if hyberMessageID != 0 {
            print("Recieved message with hyberMessageID: \(hyberMessageID)")
        }
        
        return hyberMessageID
    }
    
    // swiftlint:disable valid_docs
    
    /**
     Initalizes `HyberPushNotification` with push-notification payload
     - Parameter userInfo: Recieved push notification payload dictionary
     - Parameter isRemoteNotification: pass `true` this is remote notification,
     `false` if this is local notification
     - Returns: Initalizated `struct` if sucessfully parsed `userInfo` parameter, otherwise returns `nil`
     */
    internal init?(
        userInfo: [NSObject : AnyObject],
        isRemoteNotification: Bool)
    {
        // swiftlint:enable valid_docs
        
        let hyberMessageID = HyberPushNotification.getHyberMessageID(withUserInfo: userInfo)
        
        let firebaseMessageID: String?
        if let _firebaseMessageID = userInfo["gcm.message_id"] as? String {
            
            firebaseMessageID = _firebaseMessageID

            if hyberMessageID == 0 {
                print("recieved message from Firebase Messaging, that was not sended by Global Messaging Service (no msg_gms_uniq_id key)")
            }
            
        } else {
            
            print("No gcm.message_id")

            firebaseMessageID = .none

        }
    
        var notificationInfo: [String: AnyObject]
        
        let dataSection = userInfo.jsonFor(key: "data" as NSObject) //?? userInfo
        
        let showLocalNotification: Bool
        
        if let
            jsonNotificationInfo = dataSection?.jsonFor(key: "notification")
        {
            
            notificationInfo = jsonNotificationInfo
            
            if let aps = jsonNotificationInfo["aps"] as? [String : AnyObject] {
                aps.forEach { (keyValue: (String, AnyObject)) in
                    notificationInfo[keyValue.0] = keyValue.1
                }
            }
            
            showLocalNotification = true
            
        } else if let aps = userInfo.jsonFor(key: "aps" as NSObject) {
            
            print("no 'notification' data, using 'aps' instead")
            
            notificationInfo = aps
            
            showLocalNotification = false
            
        } else {
            
            print("no userInfo[\"notification\"] or userInfo[\"aps\"] data ")
            return nil
            
        }
        
        self = HyberPushNotification(
            withNotificationInfo: notificationInfo,
            isRemoteNotification: isRemoteNotification,
            hyberMessageID: hyberMessageID,
            firebaseMessageID: firebaseMessageID,
            sender: (dataSection?["alpha"] as? String)!, //?? HyberDataInboxSender.unknownSenderNameString,
            showLocalNotification: showLocalNotification)
        
    }
}

private extension Dictionary {
    
    func jsonFor(key key: Key) -> [String: AnyObject]? {
        
        guard let value: Value = self[key] else {
            return .none
        }
        
        if let json = value as? [String: AnyObject] {
            return json
        }
        
        guard let stringValue = value as? String else {
            return .none
        }
        
        guard let
            data = stringValue.data(using: String.Encoding.utf8),
            
            let serializedObject = try? JSONSerialization.jsonObject(
                with: data,
                options: JSONSerialization.ReadingOptions.allowFragments),
            
            let json = serializedObject as? [String: AnyObject]
            
            else {
                return .none
        }
        
        return json
        
    }
    
}

private extension UIUserNotificationSettings {
    
    static func userNotificationsAllowed() -> Bool {
        
        let userNotificationsAllowed: Bool = (UIApplication.shared.currentUserNotificationSettings?.types
            ?? UIUserNotificationType.none)
            != UIUserNotificationType.none
        
        return userNotificationsAllowed()
        
    }
    
}

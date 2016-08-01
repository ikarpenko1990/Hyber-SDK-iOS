//
//  HyberHelper+RemoteNotifications.swift
//  Hyber
//
//  Created by Vitalii Budnik on 2/10/16.
//
//

import Foundation
import UIKit

/**
 The delegate of a `Hyber` object must adopt the 
 `HyberRemoteNotificationReciever` protocol.
 Methods of the protocol allow the reciever to manage receiving of remote push-notifications
*/
public protocol HyberRemoteNotificationReciever: class {
  // swiftlint:disable line_length
  /**
   - Parameter userInfo: A dictionary that contains information related to the remote notification, 
   potentially including a badge number for the app icon, an alert sound, an alert message 
   to display to the user, a notification identifier, and custom data. The provider originates it 
   as a JSON-defined dictionary that iOS converts to an NSDictionary object; the dictionary may contain 
   only property-list objects plus NSNull. For more information about the contents of the remote notification 
   dictionary, see [Local and Remote Notification Programming Guide](xcdoc://?url=developer.apple.com/library/prerelease/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/Introduction.html#//apple_ref/doc/uid/TP40008194).
  - Parameter pushNotification: `HyberPushNotification` `struct` if notification rcieved from 
  Global Message Services, `nil` otherwise
   */
  func didReceiveRemoteNotification(
    userInfo: [NSObject : AnyObject],
    pushNotification:HyberPushNotification) // swiftlint:disable:this colon
  // swiftlint:enable line_length
}

private extension HyberHelper {
  
  /**
   Handles receiving of push-notification
   - Parameter userInfo: Recieved push notification payload dictionary
   - Returns: `HyberPushNotification` if notifications allowed, user authorized, 
   notification in correct format and saved into Inbox. Otherwise returns `nil`
   */
	func didReceiveRemoteNotification(
		userInfo: [NSObject : AnyObject])
		-> HyberPushNotification? // swiftlint:disable:this opening_brace
	{
		
		hyberLog.verbose("userInfo: \(userInfo.description)")
		
		guard let pushNotification = HyberPushNotification(
			userInfo: userInfo,
			isRemoteNotification: true)
			else {
				
				hyberLog.error("Recieved push-noficication can't be mapped to `HyberPushNotification`")
				
				return .None
				
		}
		
		internalRemoteNotificationsDelegate?.didReceiveRemoteNotification(
			userInfo,
			pushNotification: pushNotification)
		
		var showLocalNotification: Bool =
			UIApplication.sharedApplication().applicationState != .Active
			&& pushNotification.notificationsAllowed
			&& pushNotification.showLocalNotification
		
		if pushNotification.hyberMessageID != 0
			&& settings.hyberDeviceId > 0
		{
			
			hyberLog.verbose("Recieved message that was sended by Global Message Services")
			
			let requestParameters: [String : AnyObject] = [
				"uniqAppDeviceId": NSNumber(unsignedLongLong: settings.hyberDeviceId),
				"msg_gms_uniq_id": NSNumber(unsignedLongLong: pushNotification.hyberMessageID),
				"status": 1
			]
			
			hyberLog.verbose("Sending delivery report")
			
			HyberProvider.sharedInstance.POST(
				.OTTPlatform,
				"deliveryReport",
				parameters: requestParameters)
			
			showLocalNotification = showLocalNotification && pushNotification.save() != .None
			
		}
		
		if showLocalNotification {
			UIApplication.sharedApplication()
				.presentLocalNotificationNow(pushNotification.localNotification())
		}
		
		if pushNotification.firebaseMessageID != .None {
			
			Hyber.firebaseMessagingHelper?.didReceiveRemoteNotification(userInfo)
			
			if pushNotification.hyberMessageID == 0 {
				hyberLog.verbose("Recieved message that was sended by Firebase Messaging, but not from Global Message Services")
			}
			
		} else if pushNotification.hyberMessageID == 0 {
			
			hyberLog.warning("Unknown sender for recieved message")
			
		} else {
			
			hyberLog.verbose("Recieved message that was sended by Global Message Services via APNs")
			
		}
		
		hyberLog.debug("Recieved push-notification")
		
		return pushNotification
		
	}
	
  /// Handles registration for push-notification receiving
  /// - Parameter deviceToken: registered remote Apple Push-notifications device doken
  func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: NSData) {
    
    hyberLog.verbose("didRegisterForRemoteNotificationsWithDeviceToken")
    
    let newAPNsTokenString = deviceToken.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
    let oldAPNsTokenString = settings.apnsToken ?? ""
    
    if oldAPNsTokenString != newAPNsTokenString {
      
      hyberLog.verbose("New APNs Token: \"\(newAPNsTokenString)\" (was: \"\(oldAPNsTokenString)\")")
      
      settings.apnsToken = newAPNsTokenString
      
    } else {
      hyberLog.verbose("Same APNs token: \(newAPNsTokenString)")
    }
    
  }
  
}

public extension Hyber {
  
  /**
   Handles registration for push-notification receiving
   
   Call this func in 
   
   `func application(application: UIApplication, 
   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)`
   
   in your `AppDelegate` module
   
   - Parameter deviceToken: registered remote Apple Push-notifications device doken
   */
  public static func didRegisterForRemoteNotificationsWithDeviceToken(
    deviceToken: NSData) // swiftlint:disable:this opening_brace
  {
		
		hyberLog.info("New apns token came")
		
    helper.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    
    firebaseMessagingHelper?.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    
  }
  
  /**
   Handles receiving of push-notification
   
   Call this func in
   
   `func application(application: UIApplication, 
   didReceiveRemoteNotification userInfo: [NSObject : AnyObject])`
   
   in your `AppDelegate` module
   
   - Parameter userInfo: Recieved pushnotification payload dictionary
   
   - Returns: `HyberPushNotification` if notifications allowed, user authorized, 
   notification in correct format and saved into Inbox. Otherwise returns `nil`
   */
  public static func didReceiveRemoteNotification(
    userInfo: [NSObject : AnyObject])
    -> HyberPushNotification? // swiftlint:disable:this opening_brace
  {
		
		hyberLog.info("Push notification")
		
    return helper.didReceiveRemoteNotification(userInfo)
    
  }
  
}

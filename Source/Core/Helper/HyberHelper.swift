//
//  HyberObject.swift
//  Hyber
//
//  Created by Vitalii Budnik on 2/10/16.
//
//

import Foundation
import UIKit

/**
 Global Message Service Helper.
  - Note: No internal and public initializers aviable
 */
internal class HyberHelper {
  
  /// Application key. (private)
  private var applicationKey: String? = .None
  
  /// A pointer to currently running addSubscriber `Request`. (internal)
  internal var addSubscriberTask: NSURLSessionTask? = .None
  
  /// A pointer to currently running updateSubscriberInfo `Request`. (internal)
  internal var updateSubscriberInfoTask: NSURLSessionTask? = .None
	
  /// A pointer to current settings `HyberSettings`. (internal)
  internal lazy var settings: HyberSettings = {
    HyberSettings.currentSettings
  }()
  
  /// Private initializer
  private init() {}
  
  // swiftlint:disable line_length
  /// Framework remote notifications delegate (`HyberMessageFetcherJSQ`)
  internal weak var internalRemoteNotificationsDelegate: HyberRemoteNotificationReciever? = .None
  // swiftlint:enable line_length
  
}

public extension Hyber {
  
  /// An instance of `HyberHelper`
  internal static let helper = HyberHelper()
  
  /// Application key. (read-only)
  public static var applicationKey: String {
    if let applicationKey = helper.applicationKey {
      return applicationKey
    } else {
      fatalError("Hyber. You should call register() first")
    }
  }
  
	/**
	Registers framework with passed application key and `HyberGoogleCloudMessagingHelper`
	with `senderID`
	- Parameter applicationKey: `String` with yours application key
	- Parameter firebaseMessagingHelper: An instance of `HyberFirebaseMessagingHelper`,
	to be configured with SenderID, that provedes receiving of push-notifications on a device
	- Parameter launchOptions:
	A dictionary indicating the reason the app was launched (if any). The contents of this dictionary may be empty in situations where the user launched the app directly.
	Default value: `nil`.
	- Returns: `HyberPushNotification` if remote or local notification was found in passed `launchOptions` parameter
	*/
  public static func register(
    applicationKey applicationKey: String,
    firebaseMessagingHelper: HyberFirebaseMessagingHelper,
    launchOptions: [NSObject: AnyObject]? = .None) -> HyberPushNotification? // swiftlint:disable:this line_length
  {
		
		Hyber.consoleLogLevel = .Info
		hyberLog.logAppDetails()
		Hyber.fileLogLevel = .Verbose
		
		hyberLog.info("Registration")
		
    helper.applicationKey = applicationKey
		
    Hyber.firebaseMessagingHelper = firebaseMessagingHelper
		
		firebaseMessagingHelper.configureFirebaseMessaging()
		
		localize(NSLocale.preferredLanguages().first ?? "en",
		         dontCheckCurentLocale: true)
		
		guard let launchOptions = launchOptions else { return .None }
		
		let pushNotification: HyberPushNotification?
		if let remoteNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
			
			pushNotification = HyberPushNotification(userInfo: remoteNotification,
			                                         isRemoteNotification: true)
			
		} else if let localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] as? [NSObject : AnyObject] {
			
			pushNotification = HyberPushNotification(userInfo: localNotification,
			                                         isRemoteNotification: false)
			
		} else {
			pushNotification = .None
		}
		
		return pushNotification
		
  }
  
}

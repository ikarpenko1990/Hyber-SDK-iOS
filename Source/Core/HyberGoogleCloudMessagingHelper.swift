//
//  HyberGoogleCloudMessagingHelper.swift
//  Hyber
//
//  Created by Vitalii Budnik on 2/10/16.
//
//

import Foundation
import UIKit

public extension Hyber {
  /// An instance of `HyberGoogleCloudMessagingHelper` 
  public static weak var googleCloudMessagingHelper: HyberGoogleCloudMessagingHelper? = .None
  
}

/**
 Google Cloud Messaging helper `protocol`
 - Handles `UIApplicationDidBecomeActiveNotification` 
 & `UIApplicationDidEnterBackgroundNotification` to connect/dissconnect `GCMService`
 - Handles receiving Apple Device token, and remote notification
 */
public protocol HyberGoogleCloudMessagingHelper: class {
  
  /**
   Responser for `UIApplicationDidBecomeActiveNotification`.
   Connects `GCMService` to Google Cloud Messaging server
   
   - Note:
   ```swift
    func applicationDidBecomeActive() {
      // Connect to the Google Cloud Messaging server
      GCMService.sharedInstance().connectWithHandler() { error in
        if let error = error {
          // Handle error
          return
        }
      }
    }
   ```
   */
  func didBecomeActive()
  
  /** 
   Responser for `UIApplicationDidEnterBackgroundNotification`
   Disconnects `GCMService` from Google Cloud Messaging server
   - Note:
   ```swift
    func applicationDidBecomeActive() {
      // Disconnect from Google Cloud Messaging server
      GCMService.sharedInstance().disconnect()
    }
   ```
   */
  func didEnterBackground()
  
  /**
   Configures `GGLInstanceID`, and sending Google Cloud Messaging token request
   
   - Parameter deviceToken: APNs token recieved from `AppDelegate func application(application: UIApplication,
   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)`
   
   - Note:
   
   ```swift
   // Configure `GGLInstanceID`
   let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
   instanceIDConfig.delegate = self
   instanceIDConfig.logLevel = .Assert
   GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
   
   // Configure registration options
   let registrationOptions = [
    kGGLInstanceIDRegisterAPNSOption: deviceToken,
    kGGLInstanceIDAPNSServerTypeSandboxOption: true]
   
   // Configure `GGLInstanceID`
   GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(
    gcmSenderID,
    scope: kGGLInstanceIDScopeGCM,
    options: registrationOptions,
    handler: { (token, error) in
      guard let token = token else {
        // handle error
        return
      }
   
    })
   ```
   */
  func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: NSData)
  
  /** 
   Tells to `GCMService`, that remote message received
   
   - Note:
   ```swift
   func applicationDidReceiveRemoteNotification(userInfo: [NSObject: AnyObject]) {
    GCMService.sharedInstance().appDidReceiveMessage(userInfo)
   }
   ```
   */
  func didReceiveRemoteNotification(userInfo: [NSObject: AnyObject])
  
  /**
   Initializes Google Cloud Messaging with passed `senderID`.
   
   - Parameter withSenderID: Google Cloud Messaging senderID 
   (same as Project number in Google developers console)
   
   - Note:
   Your declaration must be like this
   
   ```swift
   func configure(withSenderID senderID: String) {
    gcmSenderID = senderID
   }
   ```
   */
  func configure(withSenderID senderID: String)
  
  /**
   Google Cloud Messaging senderID (same as Project number in Google developers console)
   
   Declare it like this:
   ```swift
   private (set) var gcmSenderID: String?
   ```
   */
  var gcmSenderID: String? { get }
  
  /** 
   APNs token recieved from `AppDelegate func application(application: UIApplication, 
   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)`
   Setted automatically by `Hyber.framework`
   */
  var deviceToken: NSData? { get }
  
}

public extension HyberGoogleCloudMessagingHelper {
  /// Adds `applicationDidEnterBackground` & `applicationDidBecomeActive` observers to object.
  /// Call this function on `init()` of your object
  public func addApplicationDidObservers() {
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: NSSelectorFromString("didEnterBackground"),
      name: UIApplicationDidEnterBackgroundNotification,
      object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: NSSelectorFromString("didBecomeActive"),
      name: UIApplicationDidBecomeActiveNotification,
      object: nil)
  }
  
  
  /// Removes all observers of object.
  /// Call this function on `deinit` of your object
  public func removeObservers() {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
}

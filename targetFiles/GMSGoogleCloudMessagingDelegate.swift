//
//  GMSGoogleCloudMessagingDelegate.swift
//  GMS Worldwide App
//
//  Created by Vitalii Budnik on 11/26/15.
//  Copyright © 2015 Global Message Services AG. All rights reserved.
//

import Foundation
import Google.CloudMessaging
import XCGLogger
import GlobalMessageService

class GMSGoogleCloudMessagingDelegate: NSObject, GlobalMessageServiceGoogleCloudMessagingHelper {
  
  static let sharedInstance: GMSGoogleCloudMessagingDelegate = {
    return GMSGoogleCloudMessagingDelegate()
  }()
  
  private override init() {
    super.init()
    addApplicationDidObservers()
  }
  
  deinit {
    removeObservers()
  }
  
  func configure(withSenderID senderID: String) {
    gcmSenderID = senderID
  }
  
  private (set) var gcmSenderID: String? = .None {
    didSet {
      
      let gcmConfig: GCMConfig = GCMConfig.defaultConfig()
      gcmConfig.receiverDelegate = self
      gcmConfig.useNewRemoteNotificationCallback = false
      gcmConfig.logLevel = .Assert
      
      GCMService.sharedInstance().startWithConfig(gcmConfig)
      
    }
  }
  
  private lazy var gglInstanceIDInitialized: Bool = false
  private func initializeGGLInstanceID() {
    if gglInstanceIDInitialized {
      
    }
    if !gglInstanceIDInitialized {
      let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
      instanceIDConfig.delegate = self
      instanceIDConfig.logLevel = .Assert
      GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
    }
    gglInstanceIDInitialized = true
  }
  
  private (set) var deviceToken: NSData? = .None {
    didSet {
      
      guard let deviceToken = deviceToken else { return }
      
      var changed = true
      if let oldValue = oldValue {
        changed = !deviceToken.isEqualToData(oldValue)
      }
      
      if changed {
        initializeGGLInstanceID()
        
        registrationOptions = [
          kGGLInstanceIDRegisterAPNSOption: deviceToken,
          kGGLInstanceIDAPNSServerTypeSandboxOption: true
        ]
        
        fetchGCMtoken()
        
      }
    }
  }
  
  private func fetchGCMtoken() {
    GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(
      gcmSenderID,
      scope: kGGLInstanceIDScopeGCM,
      options: registrationOptions,
      handler: registrationHandler)
  }
  
  private (set) lazy var registeredGCMtoken: String? = .None
  
  private lazy var registrationOptions = [String: AnyObject]()
  
  private var retryFetchTokenInterval: NSTimeInterval = 1
}

//MARK: ApplicationDelegate
extension GMSGoogleCloudMessagingDelegate {
  
  
  func didEnterBackground() {
    GCMService.sharedInstance().disconnect()
  }
  
  func didBecomeActive() {
    // Connect to the GCM server to receive non-APNS notifications
    GCMService.sharedInstance().connectWithHandler() { error in
      if let error = error {
        print("GMSGoogleCloudMessagingDelegate.applicationDidBecomeActive error:\n\(error)")
        return
      }
    }
  }
  
  func didReceiveRemoteNotification(userInfo: [NSObject: AnyObject]) {
    GCMService.sharedInstance().appDidReceiveMessage(userInfo)
  }
  
  func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: NSData) {
    self.deviceToken = deviceToken
  }
  
}

// MARK: GGLInstanceIDDelegate. Google Cloud Messaging Token
extension GMSGoogleCloudMessagingDelegate : GGLInstanceIDDelegate {
  
  @objc func onTokenRefresh() {
    GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(
      gcmSenderID,
      scope: kGGLInstanceIDScopeGCM,
      options: registrationOptions,
      handler: registrationHandler)
  }
  
  private func registrationHandler(registrationToken: String!, error: NSError!) {
    guard let registrationToken = registrationToken else {

      // Based on https://github.com/google/gcm/issues/138#issuecomment-178372820
      let delayTime = dispatch_time(
        DISPATCH_TIME_NOW,
        Int64(retryFetchTokenInterval * Double(NSEC_PER_SEC)))
      
      dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
        self?.fetchGCMtoken()
      }
      
      retryFetchTokenInterval += retryFetchTokenInterval
      
      return print("GMSGoogleCloudMessagingDelegate.registrationHandler bloody error:\n\(error)")
      
    }
    
    registeredGCMtoken = registrationToken
    
    GlobalMessageService.updateRegisteredGCMtoken(registeredGCMtoken)
    
  }
  
}

// MARK: GCMReceiverDelegate
extension GMSGoogleCloudMessagingDelegate : GCMReceiverDelegate {
  
  	// [START upstream_callbacks]
  	@objc func willSendDataMessageWithID(messageID: String!, error: NSError!) {
  		if (error != nil) {
  			print("Failed to send the message \(messageID): \(error.localizedDescription)")
  			// Failed to send the message.
  		} else {
  			// Will send message, you can save the messageID to track the message
  		}
  	}
  
  	@objc func didSendDataMessageWithID(messageID: String!) {
  		// Did successfully send message identified by messageID
  	}
  	// [END upstream_callback@objc s]
  
  	@objc func didDeleteMessagesOnServer() {
  		// Some messages sent to this device were deleted on the GCM server before reception, likely
  		// because the TTL expired. The client should notify the app server of this, so that the app
  		// server can resend those messages.
  	}
  	
}


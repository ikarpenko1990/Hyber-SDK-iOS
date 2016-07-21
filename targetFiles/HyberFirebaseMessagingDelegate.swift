//
//  HyberFirebaseMessagingDelegate.swift
//  Hyber
//
//  Created by Vitalii Budnik on 11/26/15.
//  Copyright © 2015 Global Message Services AG. All rights reserved.
//

import Foundation
import Firebase
import Hyber

class HyberFirebaseMessagingDelegate: NSObject, HyberFirebaseMessagingHelper {
  
  static let sharedInstance: HyberFirebaseMessagingDelegate = {
    return HyberFirebaseMessagingDelegate()
  }()
  
  private override init() {
    super.init()
    addApplicationDidObservers()
		
		NSNotificationCenter.defaultCenter()
			.addObserver(self,
			             selector: #selector(onFirebaseMessagingTokenRefresh(_:)),
			             name: kFIRInstanceIDTokenRefreshNotification,
			             object: .None)
		
  }
	
	func onFirebaseMessagingTokenRefresh(notification: NSNotification?) {
		let firebaseMessagingToken = FIRInstanceID.instanceID().token()
		
		self.firebaseMessagingToken = firebaseMessagingToken
		
		Hyber.updateFirebaseMessagingToken(firebaseMessagingToken, completionHandler: .None)
		
	}

  deinit {
    removeObservers()
  }
	
  private (set) var deviceToken: NSData? = .None {
    didSet {
      
      guard let deviceToken = deviceToken else { return }
      
      var changed = true
      if let oldValue = oldValue {
        changed = !deviceToken.isEqualToData(oldValue)
      }
      
      if changed {
				
				#if DEBUG
					FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .Sandbox)
				#else
					FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .Prod)
				#endif
				
        connectToFirebaseMessaging()
        
      }
    }
  }
  
  private func connectToFirebaseMessaging() {
		
		guard deviceToken != .None else { return }
		
		FIRMessaging.messaging().connectWithCompletion { [weak self] (error) in
			
			if (error != nil) {
				print("Unable to connect with FCM. \(error)")
			} else {
				print("Connected to FCM.")
			}
			
			self?.onFirebaseMessagingTokenRefresh(.None)
			
  	}
		
  }
	
  private (set) lazy var firebaseMessagingToken: String? = .None
  
  private lazy var registrationOptions = [String: AnyObject]()
  
  private var retryFetchTokenInterval: NSTimeInterval = 1
}

//MARK: ApplicationDelegate
extension HyberFirebaseMessagingDelegate {
  
  
  func didEnterBackground() {
    FIRMessaging.messaging().disconnect()
  }
  
  func didBecomeActive() {
		connectToFirebaseMessaging()
  }
	
	func configureFirebaseMessaging() {
		if FIRApp.defaultApp() == .None {
			FIRApp.configure()
		}
	}
  
  func didReceiveRemoteNotification(userInfo: [NSObject: AnyObject]) {
    FIRMessaging.messaging().appDidReceiveMessage(userInfo)
  }
  
  func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: NSData) {
    self.deviceToken = deviceToken
  }
  
}

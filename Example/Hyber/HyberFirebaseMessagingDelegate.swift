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
import UserNotifications

class HyberFirebaseMessagingDelegate: NSObject, HyberFirebaseMessagingHelper {
    
    static let sharedInstance: HyberFirebaseMessagingDelegate = {
        return HyberFirebaseMessagingDelegate()
    }()
    
    private override init() {
        super.init()
        addApplicationDidObservers()
        
        NotificationCenter.default.addObserver(self,selector: #selector(onFirebaseMessagingTokenRefresh),name: NSNotification.Name.firInstanceIDTokenRefresh,
                         object: .none)
        
    }
    
    func onFirebaseMessagingTokenRefresh(notification: NSNotification?) {
        let firebaseMessagingToken = FIRInstanceID.instanceID().token()
        
        self.firebaseMessagingToken = firebaseMessagingToken
        
//        Hyber.updateFirebaseMessagingToken(firebaseMessagingToken, completionHandler: .none)
        
    }
    
    deinit {
        removeObservers()
    }
    
   var deviceToken: NSData? = .none {
        didSet {
           
            guard let deviceToken = deviceToken else { return }
            
            var changed = true
            if let oldValue = oldValue {
                changed = !deviceToken.isEqual(to: oldValue as Data)
            }
            
            if changed {
                
                #if DEBUG
                    FIRInstanceID.instanceID().setAPNSToken(deviceToken as Data, type: .sandbox)
                #else
                    FIRInstanceID.instanceID().setAPNSToken(deviceToken as Data, type: .prod)
                #endif
                
                connectToFirebaseMessaging()
                
            }
        }
    }
    
     func connectToFirebaseMessaging() {
        
        guard deviceToken != .none else { return }
        
        FIRMessaging.messaging().connect { [weak self] (error) in
            
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
            
            self?.onFirebaseMessagingTokenRefresh(notification: .none)
            
        }
        
    }
    
    private (set) lazy var firebaseMessagingToken: String? = .none
    
    private lazy var registrationOptions = [String: AnyObject]()
    
    private var retryFetchTokenInterval: TimeInterval = 1
    
    
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
        if FIRApp.defaultApp() == .none {
            FIRApp.configure()
        }
    }
    
    func didReceiveRemoteNotification(userInfo: [NSObject: AnyObject]) {
        
        print("HyberFirebaseMessagingDelegate recieved push-notification")
        
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        
        
        
    }
    
    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: NSData) {
        
        print("HyberFirebaseMessagingDelegate recieved apns token")
        
        self.deviceToken = deviceToken
        
    }
    
}

/** [START ios_10_message_handling]
 You must assign your delegate object to the UNUserNotificationCenter object no later before your app finishes launching. For example, in an iOS app, you must assign it in the application(_:willFinishLaunchingWithOptions:) or application(_:didFinishLaunchingWithOptions:) method.*/

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
    }
    
    //Called to let your app know which action was selected by the user for a given notification.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Info = ",response.notification.request.content.userInfo)
        completionHandler()
    }
}


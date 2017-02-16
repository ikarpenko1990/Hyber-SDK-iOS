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
//HyberFirebaseHelper will be initialized with new RESTAPI

 class HyberFirebaseMessagingDelegate: NSObject, HyberFirebaseMessagingHelper {

    static let sharedInstance: HyberFirebaseMessagingDelegate = {
        return HyberFirebaseMessagingDelegate()
    }()
    
  private override init() {
        super.init()
        addApplicationDidObservers()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onFirebaseMessagingTokenRefresh),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        
    }
    
  public  func onFirebaseMessagingTokenRefresh(notification: NSNotification?) {
        let firebaseMessagingToken = FIRInstanceID.instanceID().token()
        print("FIREBASE TOKEN:\(firebaseMessagingToken)")
        self.firebaseMessagingToken = firebaseMessagingToken
        Hyber.saveToken(fcmToken:self.firebaseMessagingToken!)
        connectToFirebaseMessaging()
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
                self.onFirebaseMessagingTokenRefresh(notification: .none)
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
        
        FIRMessaging.messaging().connect { (error) in
            
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
            
            self.onFirebaseMessagingTokenRefresh(notification: .none)
            
        }
        
    }
    // register for recive Notification
    func registerForRemoteNotification() {
     
        
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
            
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    
    var firebaseMessagingToken: String? = .none
    
    private lazy var registrationOptions = [String: AnyObject]()
    
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
        registerForRemoteNotification()
        connectToFirebaseMessaging()
    }
    
    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any]) {
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
    }
    
    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: NSData) {
        
        
        self.deviceToken = deviceToken
        print("Device token: \(deviceToken)")
        
    }
    
}


/** [START ios_10_message_handling]
 You must assign your delegate object to the UNUserNotificationCenter object no later before your app finishes launching. For example, in an iOS app, you must assign it in the application(_:willFinishLaunchingWithOptions:) or application(_:didFinishLaunchingWithOptions:) method.*/
@available(iOS 10, *)
extension HyberFirebaseMessagingDelegate : UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        Hyber.didReceiveRemoteNotification(userInfo: notification.request.content.userInfo)
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        Hyber.didReceiveRemoteNotification(userInfo: response.notification.request.content.userInfo)
//    }
}

extension HyberFirebaseMessagingDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
    }
}

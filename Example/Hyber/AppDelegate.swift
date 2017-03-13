//
//  AppDelegate.swift
//  Hyber
//
//  Created by Taras on 10/20/2016.
//  Copyright (c) 2016 Incuube. All rights reserved.
//

import UIKit
import Hyber
import UserNotifications
import Firebase
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        HyberFirebaseMessagingDelegate.sharedInstance.configureFirebaseMessaging()
        Hyber.initialise(clientApiKey:clientApiKey,
                         firebaseMessagingHelper: HyberFirebaseMessagingDelegate.sharedInstance,
                         launchOptions: launchOptions)
        //Init fabric
        Fabric.with([Crashlytics.self, Answers.self])
        return true
        
    }
   
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        Hyber.didReceiveRemoteNotification(userInfo: userInfo)
        NotificationCenter.default.post(name: Notification.Name("GetNewPush"), object: nil)
        completionHandler(.newData)
    }
   
       
}

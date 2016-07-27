//
//  AppDelegate.swift
//  HyberDemo
//
//  Created by Vitalii Budnik on 7/20/16.
//  Copyright © 2016 Global Message Services. All rights reserved.
//

import UIKit
import Firebase
import Hyber

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		let remoteNotification = Hyber.register(applicationKey: "sww34cc290454561bd913f64685e54cm",
		               firebaseMessagingHelper: HyberFirebaseMessagingDelegate.sharedInstance,
		               launchOptions: launchOptions)
		
		print(remoteNotification)
		
		Hyber.consoleLogLevel = .Verbose
		
		application.registerForRemoteNotifications()
		
		return true
	}

	func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		
		Hyber.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
		
	}
	
	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
		
		Hyber.didReceiveRemoteNotification(userInfo)
		
		completionHandler(.NewData)
		
	}

}


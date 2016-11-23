//
//  HyberPushNotification.swift
//  Pods
//
//  Created by Taras on 10/21/16.
//
//
import Foundation
import UIKit
import UserNotifications
import SwiftyJSON
import Realm
import RealmSwift
import ObjectMapper
import AlamofireObjectMapper
/**
 The delegate of a `Hyber` object must adopt the
 `HyberRemoteNotificationReciever` protocol.
 Methods of the protocol allow the reciever to manage receiving of remote push-notifications
 */
public protocol HyberRemoteNotificationReciever: class {
 
    func didReceiveRemoteNotification(
        userInfo: [AnyHashable : Any])
}

public extension Hyber {
    
    /**
     Handles registration for push-notification receiving
     
    - Parameter deviceToken: registered remote Apple Push-notifications device doken
     */
    
    public static func didFinishLaunchingWithOptions(launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
    
    {
        let remoteNotif: AnyObject? = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as AnyObject?
        
        //Accept push notification when app is not open
        if (remoteNotif) != nil {
            
            didReceiveRemoteNotification(userInfo: remoteNotif as! [AnyHashable : Any])
        }
        
        
        func handleRemoteNotification(remoteNotif: AnyObject?){
            //handle your notification here
        }
    }
    public static func didRegisterForRemoteNotificationsWithDeviceToken(
        deviceToken: NSData)
    {
        
        HyberLogger.info("New apns token came")
        
        didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
        
        firebaseMessagingHelper?.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
        
    }
    
    /**
     Handles receiving of push-notification
     */
    public static func didReceiveRemoteNotification(
        userInfo: [AnyHashable : Any])
    {
        
        let validJson = JSON(userInfo)
        let fcmMsgID = validJson["gcm.message_id"].rawString()
        let messageString = validJson["message"].rawString()
        if let data = messageString?.data(using: String.Encoding.utf8) {
            var json = JSON(data: data)
            let hyberMsgID = json["mess_id"].rawString()
            let realm = try! Realm()
            let messages = List<Message>()
            let newMessages = Message()
            newMessages.messageId = json["mess_id"].rawString()
            newMessages.mTitle = json["alpha"].string
            newMessages.mPartner = "push"
            newMessages.mBody = json["text"].string
    
            if let optionsArray = json["options"].rawValue as? [String:Any] {
                newMessages.mImageUrl = optionsArray["img_url"] as! String
                newMessages.mButtonUrl = optionsArray["action_url"] as! String
                newMessages.mButtonText = optionsArray["caption"] as! String
            }
            
            messages.append(newMessages)
            try! realm.write {
                realm.add(newMessages, update: true)
            }
        
            if hyberMsgID != "null" {
                HyberLogger.info("Recieved message that was sended by Hyber")
                
                Hyber.sentDeliveredStatus(messageId:hyberMsgID!)
                
                HyberLogger.info("Sending delivery report ...")
            }
            
            if fcmMsgID != .none {
                if hyberMsgID == "null" {
                    
                    HyberLogger.info("Recieved message that was sended by Firebase Messaging, but not from Hyber")
                }
                
            } else {
                
                HyberLogger.info("Recieved message that was sended by Hyber via APNs")
                
            }
            let appDelegate = UIApplication.shared.delegate
            
            let murmur = Murmur(title: json["text"].string!)
            show(whistle: murmur, action: .show(0.5))
            show(whistle: murmur, action: .present)
            hide(whistleAfter: 4)
            HyberLogger.info(validJson)
        }
    
    }
}



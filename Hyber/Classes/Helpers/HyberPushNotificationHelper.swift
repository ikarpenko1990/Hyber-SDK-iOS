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
        let hyberMsgID = validJson["msg_gms_uniq_id"].rawString()
        let alfa = validJson["alpha"].rawString()
        let fcmMsgID = validJson["gcm.message_id"].rawString()
        let push = validJson["aps"].rawValue
        
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
        
        HyberLogger.info(push)
    }
    
}



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

    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any])
}

public extension Hyber {

    /**
     Handles registration for push-notification receiving
     
    - Parameter deviceToken: registered remote Apple Push-notifications device doken
     */

    public static func didFinishLaunchingWithOptions(launchOptions: [UIApplicationLaunchOptionsKey: Any]?)

    {


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
    public static func didReceiveRemoteNotification(userInfo: [AnyHashable: Any])
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
          if json["options"] != nil {
                    if let optionsArray = json["options"].rawValue as? [String: Any] {
                        if optionsArray["img_url"] is NSNull {
                            HyberLogger.info("Image:Null")
                        } else {
                            newMessages.mImageUrl = optionsArray["img_url"] as! String?
                        }
                        
                        if optionsArray["action_url"] is NSNull {
                            HyberLogger.info("Action:Null")
                        } else {
                            newMessages.mButtonUrl = optionsArray["action_url"] as! String?
                        }
                        
                        if optionsArray["caption"] is NSNull {
                          HyberLogger.info("Caption:Null")
                        } else {
                         newMessages.mButtonText = optionsArray["caption"] as! String?
                        }
                    }
                }
            messages.append(newMessages)
            try! realm.write {
                realm.add(newMessages, update: true)
            }
            if hyberMsgID != "null" {
                HyberLogger.info("Recieved message that was sended by Hyber")
                if UIApplication.shared.applicationState == .inactive {
                    Hyber.sentDeliveredStatus(messageId: hyberMsgID!)
                } else {
                    Hyber.sentDeliveredStatus(messageId: hyberMsgID!)
                }

                HyberLogger.info("Sending delivery report ...")
            }
            if fcmMsgID != .none {
                if hyberMsgID == "null" {
                    HyberLogger.info("Recieved message that was sended by Firebase Messaging, but not from Hyber")
                }
            } else {
                HyberLogger.info("Recieved message that was sended by Hyber via APNs")
            }
            LocalNotificationView.show(withImage: nil,
                                       title: json["alpha"].string,
                                       message: json["text"].string,
                                       duration: 2,
                                       onTap: { })
        }
    }


}



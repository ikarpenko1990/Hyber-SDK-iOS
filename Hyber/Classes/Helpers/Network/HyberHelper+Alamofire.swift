//
//  HyberHelper+Alamofire.swift
//  Pods
//
//  Created by Taras on 10/21/16.
//  Api Requests
//

import Foundation
import Alamofire
import CoreData
import Realm
import RealmSwift
import SwiftyJSON
import ObjectMapper
import RxSwift
import CryptoSwift


public extension Hyber {
    
    typealias CompletionHandler = (_ success: Bool) -> Void
    
    public static func registration(phoneId: String, password: String, completionHandler: @escaping CompletionHandler) {
        LogOut()
        let genericUUID = UUID.init()
        let sdkUUID = genericUUID.uuidString.lowercased()
        
        DataRealm.session(uuid: sdkUUID)
        
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": kHyberClientAPIKey!,
            "X-Hyber-IOS-Bundle-Id": kBundleID!,
            "X-Hyber-Session-Id": sdkUUID,
            ]
        
        let phoneData: Parameters = [
            "userPhone": phoneId,
            "userPass": password,
            "osType": kOSType,
            "osVersion": kOSVersion,
            "deviceType": kDeviceType,
            "deviceName": kDeviceName,
            "sdkVersion": "2.2.0"
        ]
       
        HyberLogger.info("Session id: \(headers),  Phone info: \(phoneData)")
      
        Networking.registerRequest(parameters: phoneData, headers: headers)
            .subscribe(onNext: { _ in
                let flag = true
                completionHandler(flag)
                HyberLogger.debug("Register new subscriber")
                updateDevice()
            }, onError: { HyberLogger.info("Error", $0)
                let flag = false // false if download fail
                completionHandler(flag)
            })
    }

    public static func getMessageList(completionHandler: @escaping CompletionHandler) -> Void {
       let realm = try! Realm()
        if realm.objects(User.self).first?.mPhone == nil {
            let flag = false
            completionHandler(flag)
            HyberLogger.info("Please register user session")
        } else {
            let token: String = realm.objects(Session.self).last!.mToken!
            let kUUID:String = realm.objects(Session.self).first!.mSessionToken!
            let date = NSDate()
                try! realm.write {
                    realm.delete(realm.objects(Message.self))
                }
            let timestamp = UInt64(floor(date.timeIntervalSince1970 * 1000))
            let timeString = String(timestamp)
            let shaPass = token + ":" + timeString
            let crytped = shaPass.sha256()
            let headers = [
                "Content-Type": "application/json",
                "X-Hyber-Session-Id":  "\(kUUID)",
                "X-Hyber-Auth-Token": "\(crytped)",
                "X-Hyber-Timestamp": "\(timeString)"
                ]
            let parameters : Parameters = [
                "startDate": timestamp
            ]
       
        Networking.getMessagesRequest(parameters: parameters, headers: headers)
                .subscribe(onNext: { _ in
                    let flag = true
                    completionHandler(flag)
                    HyberLogger.debug("Messages loaded")

                }, onError: { let flag = false
                    completionHandler(flag)
                HyberLogger.info("Error", $0)
                })
            }
      }

    public static func sendMessageCallback(messageId: String, message: String?, completionHandler: @escaping CompletionHandler) -> Void {
        let realm = try! Realm()
         if realm.objects(User.self).first?.mPhone == nil {
            let flag = false
            completionHandler(flag)
            HyberLogger.info("Please register user session")
        } else {
            if (message?.isEmpty)! {
                HyberLogger.info("String is empty, please input message")
                let flag = false
                completionHandler(flag)
                return
            }
            
            let token: String = realm.objects(Session.self).last!.mToken!
            let kUUID:String = realm.objects(Session.self).first!.mSessionToken!
            let date = NSDate()
            let timestamp = UInt64(floor(date.timeIntervalSince1970 * 1000))
            let timeString = String(timestamp)
            let shaPass = token + ":" + timeString
            let crytped = shaPass.sha256()
            let headers = [
                "Content-Type": "application/json",
                "X-Hyber-Session-Id": "\(kUUID)",
                "X-Hyber-Auth-Token": "\(crytped)",
                "X-Hyber-Timestamp": "\(timeString)"
                ]
            let params: Parameters = [
                "messageId": messageId,
                "answer": message!
                ]

            let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            let decoded = try! JSONSerialization.jsonObject(with: jsonData, options: [])

            Networking.sentBiderectionalMessage(parameters: decoded as! [String: AnyObject], headers: headers )
                .subscribe(onNext: { _ in
                    let flag = true
                    completionHandler(flag)
                },
                onError: { HyberLogger.info("Error", $0)
                    let flag = false
                    completionHandler(flag)
                },
                onCompleted: {
                    let flag = true
                    completionHandler(flag)
                    HyberLogger.info("Message sented")
            })
        }
    }
    
    public static func revokeDevice(deviceId: NSArray, completionHandler: @escaping CompletionHandler) -> Void {
        let realm = try! Realm()
         if realm.objects(User.self).first?.mPhone == nil {
            let flag = false
            completionHandler(flag)
            HyberLogger.info("Please register user session")
        } else {
            let token: String = realm.objects(Session.self).last!.mToken!
            let kUUID:String = realm.objects(Session.self).first!.mSessionToken!
            let date = NSDate()
            let timestamp = UInt64(floor(date.timeIntervalSince1970 * 1000))
            let timeString = String(timestamp)
            let shaPass = token + ":" + timeString
        let crytped = shaPass.sha256()
       
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Session-Id":  "\(kUUID)",
            "X-Hyber-Auth-Token": "\(crytped)",
            "X-Hyber-Timestamp": "\(timeString)"
            ]
        
        let params: [String: AnyObject] = [
            "devices": deviceId
            ]

        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        let decoded = try! JSONSerialization.jsonObject(with: jsonData, options: [])
        
            Networking.deleteDevice(parameters: decoded as! [String: AnyObject], headers: headers )
                .subscribe(onNext: { _ in
                    let flag = true
                    completionHandler(flag)
                },
                onError: { HyberLogger.info("Error", $0)
                    let flag = false
                    completionHandler(flag)
                })
        }
    }
    
   public static func getDeviceList(completionHandler: @escaping CompletionHandler) -> Void {
        let realm = try! Realm()
         if realm.objects(User.self).first?.mPhone == nil {
                let flag = false
                completionHandler(flag)
                HyberLogger.info("Please register user session")
            } else {
                let token: String = realm.objects(Session.self).last!.mToken!
                let kUUID:String = realm.objects(Session.self).first!.mSessionToken!
                try! realm.write {
                     realm.delete(realm.objects(Device.self))
                }
                let date = NSDate()
                let timestamp = UInt64(floor(date.timeIntervalSince1970 * 1000))
                let timeString = String(timestamp)
                let shaPass = token + ":" + timeString
                let crytped = shaPass.sha256()
           
                let headers = [
                    "Content-Type": "application/json",
                    "X-Hyber-Session-Id":  "\(kUUID)",
                    "X-Hyber-Auth-Token": "\(crytped)",
                    "X-Hyber-Timestamp": "\(timeString)"
                ]
                
            Networking.getDeviceInfoRequest(parameters: nil, headers: headers)
                .subscribe(onNext: { _ in
                    let flag = true
                    completionHandler(flag)
                    updateDevice()
                },
                onError: {
                    HyberLogger.info("Error", $0)
                    let flag = false
                    completionHandler(flag)
                })
        }
    }
    
    //Network handler
    
    public static func fetchMessageArea(completionHandler: @escaping (AnyObject?, Error?) -> ()) {
        let realm = try! Realm()
        if realm.objects(User.self).first?.mPhone == nil {
            HyberLogger.info("Please register user session")
        } else {
            let token: String = realm.objects(Session.self).last!.mToken!
            let kUUID:String = realm.objects(Session.self).first!.mSessionToken!
            let date = NSDate()
            try! realm.write {
                realm.delete(realm.objects(Message.self))
            }
            let timestamp = UInt64(floor(date.timeIntervalSince1970 * 1000))
            let timeString = String(timestamp)
            let shaPass = token + ":" + timeString
            let crytped = shaPass.sha256()
            let headers = [
                "Content-Type": "application/json",
                "X-Hyber-Session-Id":  "\(kUUID)",
                "X-Hyber-Auth-Token": "\(crytped)",
                "X-Hyber-Timestamp": "\(timeString)"
            ]
            let parameters : Parameters = [
                "startDate": timestamp
            ]
                Networking.getMessagesArea(parameters: parameters, headers: headers, completionHandler: completionHandler)
            
        }
    }
    
    public static func fetchDeviceList(completionHandler: @escaping (AnyObject?, Error?) -> ()) {
        let realm = try! Realm()
        if realm.objects(User.self).first?.mPhone == nil {
            HyberLogger.info("Please register user session")
        } else {
            let token: String = realm.objects(Session.self).last!.mToken!
            let kUUID:String = realm.objects(Session.self).first!.mSessionToken!
            try! realm.write {
                realm.delete(realm.objects(Device.self))
            }
            let date = NSDate()
            let timestamp = UInt64(floor(date.timeIntervalSince1970 * 1000))
            let timeString = String(timestamp)
            let shaPass = token + ":" + timeString
            let crytped = shaPass.sha256()
            
            let headers = [
                "Content-Type": "application/json",
                "X-Hyber-Session-Id":  "\(kUUID)",
                "X-Hyber-Auth-Token": "\(crytped)",
                "X-Hyber-Timestamp": "\(timeString)"
            ]
            
            Networking.getDeviceArea(parameters: nil, headers: headers, completionHandler: completionHandler)
        }
    }

}

extension Hyber {

    static func updateDevice() -> Void {
        let realm = try! Realm()
         if realm.objects(User.self).first?.mPhone == nil {
            HyberLogger.info("Please register user session")
        } else {
            let token: String = realm.objects(Session.self).last!.mToken!
            let kUUID:String = realm.objects(Session.self).first!.mSessionToken!
            let date = NSDate()
            let timestamp = UInt64(floor(date.timeIntervalSince1970 * 1000))
            let timeString = String(timestamp)
            let shaPass = token + ":" + timeString
            let crytped = shaPass.sha256()
            let headers = [
                "Content-Type": "application/json",
                "X-Hyber-Session-Id":  "\(kUUID)",
                "X-Hyber-Auth-Token": "\(crytped)",
                "X-Hyber-Timestamp": "\(timeString)"
                ]
            let phoneData: Parameters = [
                "fcmToken": kFCM!,
                "osType": kOSType,
                "osVersion": kOSVersion,
                "deviceType": kDeviceType,
                "deviceName": kDeviceName,
                "sdkVersion": "2.2.0"
            ]
            HyberLogger.info("Phone info:\(phoneData)")
            
            Networking.updateDeviceRequest(parameters: phoneData, headers: headers)
                .subscribe(onNext: { _ in
                },
                onError: { HyberLogger.info("Error", $0)
                },
                onCompleted: { HyberLogger.info("Device updated")
                })
        }
    }

    static func sentDeliveredStatus(messageId: String?) -> Void {
        let realm = try! Realm()
         if realm.objects(User.self).first?.mPhone == nil {
            HyberLogger.info("Please register user session")
        } else {
            let token: String = realm.objects(Session.self).last!.mToken!
            let kUUID:String = realm.objects(Session.self).first!.mSessionToken!
            let date = NSDate()
            let timestamp = UInt64(floor(date.timeIntervalSince1970 * 1000))
            let timeString = String(timestamp)
            let shaPass = token + ":" + timeString
            let crytped = shaPass.sha256()
            let headers = [
                "Content-Type": "application/json",
                "X-Hyber-Session-Id":  "\(kUUID)",
                "X-Hyber-Auth-Token": "\(crytped)",
                "X-Hyber-Timestamp": "\(timeString)"
                ]

            let params: Parameters = [
                "messageId": messageId!
            ]

            let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            let decoded = try! JSONSerialization.jsonObject(with: jsonData, options: [])

            Networking.sentDeliveredStatus(parameters: decoded as! [String: AnyObject], headers: headers )
                .subscribe(onNext: { _ in
                    let utc = date.toString()
                    try! realm.write {
                        realm.create(Message.self, value: ["messageId": messageId!, "isReported": true, "mDate": "\(utc)"], update: true)
                    }
                    HyberLogger.info("Delivered report")
                },
                onError: { HyberLogger.info("Error", $0)
                })
        }
    }
    
}

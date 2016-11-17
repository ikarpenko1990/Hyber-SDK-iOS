//
//  HyberHelper+Alamofire.swift
//  Pods
//
//  Created by Taras on 10/21/16.
// 
//  Api Requests
// 

import Foundation
import Alamofire
import CoreData
import Realm
import RealmSwift
import SwiftyJSON
import ObjectMapper
import AlamofireObjectMapper
import RxSwift

public extension Hyber {
  
    typealias CompletionHandler = (_ success:Bool) -> Void

    public static func registration(phoneId: String, completionHandler: @escaping CompletionHandler) {
        let disposeBag = DisposeBag()

        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key":kHyberClientAPIKey!,
//            "X-Hyber-IOS-Bundle-Id":kBundleID!,
            "X-Hyber-App-Fingerprint":"Q0hsXHsrc+n04JA0+jmZ+J0cz9o=",
            "X-Hyber-Installation-Id": kUUID,
            "sdkVersion":"2.1.0"

            ]
        
        let phoneData: Parameters = [
            "userPhone": phoneId,
            "osType": kOSType,
            "osVersion": kOSVersion,
            "deviceType": kDeviceType,
            "deviceName": kDeviceName,
            "fcmToken": kFCM,
            "sdkVersion":"2.1.0"
            
        ]
        
        Networking.registerRequest(parameters: phoneData, headers: headers)
            .subscribe(onNext: { DataResponse  in
                let json = JSON(DataResponse)
                let flag = true // true if download succeed,false otherwise
                completionHandler(flag)

                updateDevice()
            }, onError: { print("Error", $0)
                let flag = false // false if download succeed,false otherwise
                completionHandler(flag)
            },
               onCompleted: { HyberLogger.debug("Register new subscriber")},
               onDisposed:  { HyberLogger.debug("disposed")}
         )
        
    }



    public static func updateDevice()  -> Void
        {
        let disposeBag = DisposeBag()

        let realm = try! Realm()
        var token: String = realm.objects(Session.self).first!.mToken!
        
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key":kHyberClientAPIKey!,
            //            "X-Hyber-IOS-Bundle-Id":kBundleID!,
            "X-Hyber-App-Fingerprint":"Q0hsXHsrc+n04JA0+jmZ+J0cz9o=",
            "X-Hyber-Installation-Id": kUUID,
            "X-Hyber-Auth-Token": token,
            "sdkVersion":"2.1.0"
        ]
        let phoneData: Parameters = [
            "fcmToken": kFCM,
            "priority": 0,
            "osType": kOSType,
            "osVersion": kOSVersion,
            "deviceType": kDeviceType,
            "deviceName": kDeviceName,
            "modelName": kDeviceName,
            ] as [String : Any]
                
        Networking.updateDeviceRequest(parameters: phoneData, headers: headers)
            .subscribe(onNext: {json in
                let json = JSON(json)
            },onError: { print("Error", $0)},
              onCompleted: { HyberLogger.debug("Device updated")},
              onDisposed:  { HyberLogger.debug("disposed")})
    }
    
     public static func refreshAuthToken() -> Void
    {
        let realm = try! Realm()
        var token: String = realm.objects(Session.self).first!.mToken!
        var refreshToken: String = realm.objects(Session.self).first!.mRefreshToken!
        
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key":kHyberClientAPIKey!,
            //            "X-Hyber-IOS-Bundle-Id":kBundleID!,
            "X-Hyber-App-Fingerprint":"Q0hsXHsrc+n04JA0+jmZ+J0cz9o=",
            "X-Hyber-Installation-Id": kUUID,
            "X-Hyber-Auth-Token": token,
            "sdkVersion":"2.1.0"
        ]
        let parameters: Parameters = [
            "refreshToken":refreshToken
        ]
        Networking.refreshAuthTokenRequest(parameters: parameters, headers:headers)
            .subscribe(onNext: { json in
                let json = JSON(json)
                print(json)
            },onError: { print("Error", $0)},
              onCompleted: { HyberLogger.debug("Token refreshed")},
              onDisposed:  { HyberLogger.debug("disposed")})
    }
    
    
    public static func getMessageList(completionHandler: @escaping CompletionHandler) -> Void
    {
        let realm = try! Realm()
        var token: String = realm.objects(Session.self).first!.mToken!
   
        var date = NSDate()
        var timestamp = UInt64(floor(date.timeIntervalSince1970 * 1000))
        
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": kHyberClientAPIKey!,
            //            "X-Hyber-IOS-Bundle-Id":kBundleID!,
            "X-Hyber-App-Fingerprint":"Q0hsXHsrc+n04JA0+jmZ+J0cz9o=",
            "X-Hyber-Installation-Id": kUUID,
            "X-Hyber-Auth-Token": token,
            "sdkVersion":"2.1.0"
        ]
        let params:Parameters = [
            "startDate":timestamp
        ]
        
        Networking.getMessagesRequest(parameters: params, headers: headers)
            .subscribe(onNext: { json in
                let json = JSON(json)
                let flag = true
                completionHandler(flag)
                
            }, onError: { print("Error", $0)},
               onCompleted: { HyberLogger.debug("Messages loaded")
                let flag = false
                completionHandler(flag)
            },
               onDisposed:  { HyberLogger.debug("disposed")})
    }

   

    
    static func sentDeliveredStatus(messageId: String?) -> Void
    {
        let realm = try! Realm()
        var token: String = realm.objects(Session.self).first!.mToken!
        var date = NSDate()
        var timestamp = UInt64(floor(date.timeIntervalSince1970 * 1000))
        
        let authToken = Session()
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": kHyberClientAPIKey!,
            //            "X-Hyber-IOS-Bundle-Id":kBundleID!,
            "X-Hyber-App-Fingerprint":"Q0hsXHsrc+n04JA0+jmZ+J0cz9o=",
            "X-Hyber-Installation-Id": kUUID,
            "X-Hyber-Auth-Token": token,
            "sdkVersion":"2.1.0"
        ]
        
        
        let params = [
            "messageId": messageId!,
            "recivedAt": timestamp
            ] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)

        HyberLogger.debug("JSON", params)
        Networking.sentDeliveredStatus(parameters: params, headers: headers)
            .subscribe(onNext: { json in
                HyberLogger.debug("Done")
            },onError: { print("Error", $0)},
              onCompleted: { HyberLogger.debug("Delivered")},
              onDisposed:  { HyberLogger.debug("disposed")})
    }
    /*** Next API release**/
    public static func sendMessageCallback(messageId: Int ,message: String?) -> Void
    {
        let realm = try! Realm()
        var token: String = realm.objects(Session.self).first!.mToken!
        
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": kHyberClientAPIKey!,
            //            "X-Hyber-IOS-Bundle-Id":kBundleID!,
            "X-Hyber-App-Fingerprint":"Q0hsXHsrc+n04JA0+jmZ+J0cz9o=",
            "X-Hyber-Installation-Id": kUUID,
            "X-Hyber-Auth-Token": token,
            "sdkVersion":"2.1.0"
        ]
        let params: Parameters = [
            "messageId": messageId,
            "answer":message]
        
    }

    public static func deleteDevice(deviceId: String) -> Void
    {
        let realm = try! Realm()
        var token: String = realm.objects(Session.self).first!.mToken!
        
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": kHyberClientAPIKey!,
            //            "X-Hyber-IOS-Bundle-Id":kBundleID!,
            "X-Hyber-App-Fingerprint":"Q0hsXHsrc+n04JA0+jmZ+J0cz9o=",
            "X-Hyber-Installation-Id": kUUID,
            "X-Hyber-Auth-Token": token,
            "sdkVersion":"2.1.0"
        ]
        
        let params:Parameters = [
            "deviceId": deviceId
        ]
        
        Networking.deleteDevice(parameters: params, headers: headers)
            .subscribe(onNext: { json in
                let json = JSON(json)
                print(json)
            }, onError: { print("Error", $0)
            })
    }
    
    public static func getDeviceInfo() -> Void {
        let realm = try! Realm()
        var token: String = realm.objects(Session.self).first!.mToken!
        
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": kHyberClientAPIKey!,
            //            "X-Hyber-IOS-Bundle-Id":kBundleID!,
            "X-Hyber-App-Fingerprint":"Q0hsXHsrc+n04JA0+jmZ+J0cz9o=",
            "X-Hyber-Installation-Id": kUUID,
            "X-Hyber-Auth-Token": token,
            "sdkVersion":"2.1.0"
        ]
        print(headers)
        
        Networking.getDeviceInfoRequest(parameters: nil, headers: headers)
            .subscribe(onNext: { json in
                let json = JSON(json)
                print(json)
            }, onError: { print("Error", $0)
            })
    }

    
    
}



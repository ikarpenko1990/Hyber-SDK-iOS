//
//  HyberHelper+Alamofire.swift
//  Pods
//
//  Created by Taras on 10/21/16.
// 
// Api Requests
// 

import Foundation
import Alamofire
import CoreData

internal class HyberHelper_Alamofire {
 
    
}


public extension Hyber{

    
    public static func registration() -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    {
        
        let headers = [
             "Content-Type": "application/json",
             "X-Hyber-SDK-Version:": "2.0",
             "X-Hyber-Client-API-Key": "e5eb9bd59ca57000e189f9340bc285d2",
             "X-Hyber-IOS-Bundle-Id": "com.gmsu.hyber.test",
             "X-Hyber-Installation-Id": "\(UIDevice.current.identifierForVendor!.uuidString)"
             ]
        let phoneData = [
            "userPhone":"380937431520",
            "osType": "\(kOSType)",
            "osVersion": kOSVersion,
            "deviceType": "\(kDeviceType)",
            "deviceName": kDeviceName,
        
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: phoneData, options: .prettyPrinted)
        let jsonHeader = try! JSONSerialization.data(withJSONObject: headers, options: .prettyPrinted)
        let decoded = try! JSONSerialization.jsonObject(with: jsonData, options: [])
        let decodeHeaders = try! JSONSerialization.jsonObject(with: jsonHeader, options: [])
        print("Header: \(decodeHeaders)")
        print("Upload JSON: \(decoded)")
   
        Alamofire.upload(jsonData, to: kRegUrl, method: .post, headers: headers).response { response in // method defaults to `.post`
            debugPrint(response)

        }

    }
    
    
    public static func updateInfo() -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    {
        
        let headers = [
            "Hyber-SDK-Version:": "2.0",
            "Hyber-Client-API-Key": "e5eb9bd59ca57000e189f9340bc285d2",
            "Hyber-App-Fingerprint": "com.gmsu.Hyber",
            "Hyber-Installation-Id": "\(kUUID)"
        ]
        let phoneData = [
            "fcmToken":"ey5zYtte534:APA91bEhtpq9j2r1mfiH2lS9qA44DTfZGElH...",
            "priority":0,
            "osType":"IOS",
            "osType": kOSType,
            "osVersion": kOSVersion,
            "deviceType": kDeviceType,
            "deviceName": kDeviceName,
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: phoneData, options: .prettyPrinted)
        
        Alamofire.upload(jsonData, to: "https://mobile.hyber.im/api/v1/user/registration", method: .post, headers: headers).response { response in // method defaults to `.post`
            debugPrint(response)
        }
        
    }
    
    
    public static func updateFirebaseToken() -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    {
        
        let headers = [
            "Hyber-SDK-Version:": "2.0",
            "Hyber-Client-API-Key": "e5eb9bd59ca57000e189f9340bc285d2",
            "Hyber-App-Fingerprint": "com.gmsu.Hyber",
            "Hyber-Installation-Id": "\(UIDevice.current.identifierForVendor!.uuidString)"
        ]
        let phoneData = ["refreshToken":"+380937431520"]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: phoneData, options: .prettyPrinted)
        let decoded = try! JSONSerialization.jsonObject(with: jsonData, options: [])
        print("Upload JSON: \(decoded)")
        Alamofire.upload(jsonData, to: kRegUrl, method: .post, headers: headers).response { response in // method defaults to `.post`
            debugPrint(response)
            
        }
    }
    
    
    public static func getUserInfo() -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    {
        
        let headers = [
            "Hyber-SDK-Version:": "2.0",
            "Hyber-Client-API-Key": "e5eb9bd59ca57000e189f9340bc285d2",
            "Hyber-App-Fingerprint": "com.gmsu.Hyber",
            "Hyber-Installation-Id": "\(UIDevice.current.identifierForVendor!.uuidString)",
            "Hyber-Auth-Token": "heretokengms"
        ]
        
        Alamofire.upload( to: kRegUrl, method: .post, headers: headers).response { response in // method defaults to `.post`
            debugPrint(response)
            
        }
    }
    
    public static func getMessageHistory() -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    {
        
        let headers = [
            "Hyber-SDK-Version:": "2.0",
            "Hyber-Client-API-Key": "e5eb9bd59ca57000e189f9340bc285d2",
            "Hyber-App-Fingerprint": "com.gmsu.Hyber",
            "Hyber-Installation-Id": "\(UIDevice.current.identifierForVendor!.uuidString)",
            "Hyber-Auth-Token": "heretokengms"
        ]
        
        Alamofire.upload( to: kRegUrl, method: .post, headers: headers).response { response in // method defaults to `.post`
            debugPrint(response)
            
        }
    }
    
    
    public static func getFreshMessages() -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    {
        
        let headers = [
            "Hyber-SDK-Version:": "2.0",
            "Hyber-Client-API-Key": "e5eb9bd59ca57000e189f9340bc285d2",
            "Hyber-App-Fingerprint": "com.gmsu.Hyber",
            "Hyber-Installation-Id": "\(UIDevice.current.identifierForVendor!.uuidString)",
            "Hyber-Auth-Token": "heretokengms"
        ]
        
        Alamofire.upload(jsonData, to: kRegUrl, method: .post, headers: headers).response { response in // method defaults to `.post`
            debugPrint(response)
            
        }
    }

    
    public static func sendMessageCallback() -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    {
        
        let headers = [
            "Hyber-SDK-Version:": "2.0",
            "Hyber-Client-API-Key": "e5eb9bd59ca57000e189f9340bc285d2",
            "Hyber-App-Fingerprint": "com.gmsu.Hyber",
            "Hyber-Installation-Id": "\(UIDevice.current.identifierForVendor!.uuidString)",
            "Hyber-Auth-Token": "heretokengms"
        ]
        
        print("Upload JSON: \(decoded)")
        Alamofire.upload(jsonData, to: kRegUrl, method: .post, headers: headers).response { response in // method defaults to `.post`
            debugPrint(response)
            
        }
    }

    
}


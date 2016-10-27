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
import RealmSwift

internal class HyberHelper_Alamofire {
 
}


public extension Hyber{
    
    public static func registration(phoneId: String, hyberToken: String) -> Void //HyberPushNotification? //  swiftlint:disable:this line_length

    {
        
        let headers = [
             "Content-Type": "application/json",
             "X-Hyber-SDK-Version:": "2.0",
             "X-Hyber-Client-API-Key": hyberToken,
             "X-Hyber-IOS-Bundle-Id": kBundleID!,
             "X-Hyber-Installation-Id": kUUID,
             ]
        let phoneData = [
            "userPhone": phoneId,
            "osType": "\(kOSType)",
            "osVersion": kOSVersion,
            "deviceType": "\(kDeviceType)",
            "deviceName": kDeviceName,
        
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: phoneData, options: .prettyPrinted)
        let jsonHeader = try! JSONSerialization.data(withJSONObject: headers, options: .prettyPrinted)
        let decoded = try! JSONSerialization.jsonObject(with: jsonData, options: [])
        let decodeHeaders = try! JSONSerialization.jsonObject(with: jsonHeader, options: [])
        HyberLogger.info("Header: \(decodeHeaders)")
        HyberLogger.info("Upload JSON: \(decoded)")
        
        Alamofire.upload(jsonData, to: kRegUrl, method: .post, headers: headers).response { response in // method defaults to `.post`
            debugPrint(response)
            
        }
        
    }
    
    
    public func updateInfo() -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    
    {
        
        let headers = [
            "Hyber-SDK-Version:": "2.0",
            "Hyber-Client-API-Key": "e5eb9bd59ca57000e189f9340bc285d2",
            "Hyber-IOS-Bundle-Id": "com.gmsu.Hyber",
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
            "X-Hyber-SDK-Version:": "2.0",
            "X-Hyber-Client-API-Key": "e5eb9bd59ca57000e189f9340bc285d2",
            "X-Hyber-IOS-Bundle-Id": "com.gmsu.Hyber",
            "X-Hyber-Installation-Id": "\(UIDevice.current.identifierForVendor!.uuidString)"
        ]
        let phoneData = ["refreshToken":"+380937431520"]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: phoneData, options: .prettyPrinted)
        let decoded = try! JSONSerialization.jsonObject(with: jsonData, options: [])
        print("Upload JSON: \(decoded)")
        Alamofire.upload(jsonData, to: kRegUrl, method: .post, headers: headers).response { response in // method defaults to `.post`
            debugPrint(response)
            
        }
    }
    
    
    public func getUserInfo() -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    
    {
        let headers = [
            "X-Hyber-SDK-Version:": "2.0",
            "X-Hyber-Client-API-Key": "e5eb9bd59ca57000e189f9340bc285d2",
            "X-Hyber-App-Fingerprint": "com.gmsu.Hyber",
            "X-Hyber-Installation-Id": "\(UIDevice.current.identifierForVendor!.uuidString)",
            "X-Hyber-Auth-Token": "heretokengms"
        ]
        
        Alamofire.request(kGetUserData, method: .get, parameters: headers, encoding: JSONEncoding.default)
            .downloadProgress(queue: DispatchQueue.main) { progress in
                print("Progress: \(progress.fractionCompleted)")
            }
            .validate { request, response, data in
                // Custom evaluation closure now includes data (allows you to parse data to dig out error messages if necessary)
                return .success
            }
            .responseJSON { response in
                debugPrint(response)
        }

    }

    public static func getMessageHistory() -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    {
        
        let headers = [
            "X-Hyber-SDK-Version:": "2.0",
            "X-Hyber-Client-API-Key": "e5eb9bd59ca57000e189f9340bc285d2",
            "X-Hyber-IOS-Bundle-Id": "com.gmsu.Hyber",
            "X-Hyber-Installation-Id": "\(UIDevice.current.identifierForVendor!.uuidString)",
            "X-Hyber-Auth-Token": "heretokengms"
        ]
        
        let phoneData = ["refreshToken":"+380937431520"]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: phoneData, options: .prettyPrinted)
        Alamofire.upload(jsonData, to: kRegUrl, method: .post, headers: headers).response { response in // method defaults to `.post`
            debugPrint(response)
            
        }

    }
    
    
    public static func getFreshMessages() -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    {
        
        let headers = [
            "X-Hyber-SDK-Version:": "2.0",
            "X-Hyber-Client-API-Key": "e5eb9bd59ca57000e189f9340bc285d2",
            "X-Hyber-IOS-Bundle-Id": "com.gmsu.Hyber",
            "X-Hyber-Installation-Id": "\(UIDevice.current.identifierForVendor!.uuidString)",
            "X-Hyber-Auth-Token": "heretokengms"
        ]
        let phoneData = ["refreshToken":"+380937431520"]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: phoneData, options: .prettyPrinted)
        Alamofire.upload(jsonData, to: kRegUrl, method: .post, headers: headers).response { response in // method defaults to `.post`
            debugPrint(response)
            
        }
    }

    
    public static func sendMessageCallback() -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    {
        
        let headers = [
            "X-Hyber-SDK-Version:": "2.0",
            "X-Hyber-Client-API-Key": "e5eb9bd59ca57000e189f9340bc285d2",
            "X-Hyber-IOS-Bundle-Id": "com.gmsu.Hyber",
            "X-Hyber-Installation-Id": "\(UIDevice.current.identifierForVendor!.uuidString)",
            "X-Hyber-Auth-Token": "heretokengms"
        ]
        
        let phoneData = ["refreshToken":"+380937431520"]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: phoneData, options: .prettyPrinted)
        Alamofire.upload(jsonData, to: kRegUrl, method: .post, headers: headers).response { response in // method defaults to `.post`
            debugPrint(response)
            
        }
    }

    
}


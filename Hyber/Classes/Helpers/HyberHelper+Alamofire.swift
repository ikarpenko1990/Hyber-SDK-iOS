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
import Realm
import RealmSwift
import SwiftyJSON
import AlamofireObjectMapper
import RxSwift

public extension Hyber{
    
    public static func registration(phoneId: String, hyberToken: String) -> Void {
        
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": hyberToken,
            "X-Hyber-IOS-Bundle-Id":kBundleID!,
            "X-Hyber-Installation-Id": kUUID,
            ]
        let phoneData: Parameters = [
            "userPhone": phoneId,
            "osType": kOSType,
            "osVersion": kOSVersion,
            "deviceType": kDeviceType,
            "deviceName": kDeviceName,
            "sdkVersion": "2.0.0"
            
        ]
       let registraion = request(.post, baseUrlDev + kRegUrl, parameters: phoneData, encoding:  JSONEncoding.prettyPrinted, headers: headers)
        .flatMap {
            $0
                .validate(statusCode: 200 ..< 200)
                .validate(contentType: ["application/json"])
                            .rx.progress()
        }
        .observeOn(MainScheduler.instance)
        .subscribe { print($0) }

    
    }
   
    //for test without server but with delivered DATA
    public static func  testDeliveredData() -> Void
    {
        let userw = List<User>()

        Alamofire.request("http://test/responce.json").responseJSON {(response: DataResponse<Any>) in
           debugPrint(response)
            switch(response.result) {
            
            case .success:
                guard response.result.isSuccess,
                let value = response.result.value else {
                    HyberLogger.error("Can't get data")
                    return
                }
                
                let json = JSON(value)
                print(json)
                
 
                break
                
            case .failure:
                
                if let statusCode = response.response?.statusCode {
                    if statusCode == 1131 {
                        
                    }
                }
                HyberLogger.debug(response.response?.statusCode)
                
                break
            }
        }
        print(kBundleID!, kUUID,kOSType,kOSVersion,kDeviceType,kDeviceName)
    }
    
    
    
    public static func updateDevice(fcmToken: String) -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    {
    
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": "b5a5b6f4-5af7-11e6-8b77-86f30ca893d3",
            "X-Hyber-IOS-Bundle-Id":"\(kBundleID!)",
            "X-Hyber-Installation-Id": kUUID,
            "X-Hyber-Auth-Token":"4a2a1f73-f714-4b89-b5b1-64d08b54c973"
        ]
        
        let phoneData: Parameters = [
            "fcmToken": fcmToken,
            "osType": kOSType,
            "osVersion": kOSVersion,
            "deviceType": kDeviceType,
            "deviceName": kDeviceName,
            "sdkVersion":"2.1.0"
            ] as [String : Any]
        print(phoneData)
        Alamofire.request( baseUrlDev + kUpdateUrl, method: .post, parameters:phoneData, encoding: JSONEncoding.default, headers: headers).responseJSON {(response: DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    HyberLogger.debug(response.result.value)
                    
                }
                break
                
            case .failure(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 2100 {
                        HyberLogger.debug("2100, Headers format in api request is wrong")
                    }
                    if statusCode == 2101 {
                        HyberLogger.debug("2101, Json format in api request is wrong")
                    }
                    if statusCode == 2110 {
                        HyberLogger.debug("2101,The client api key used in the request is incorrect")
                    }
                    if statusCode == 2112 {
                        HyberLogger.debug("2112,The iOS Bundle Id used in the request is incorrect")
                    }
                    if statusCode == 2113 {
                        HyberLogger.debug("2113,The Installation Id used in the request is incorrect")
                    }
                    if statusCode == 2120 {
                        HyberLogger.debug("2120,Unspecified error when checking client settings")
                    }
                    if statusCode == 2121 {
                        HyberLogger.debug("2121,Not configured settings for the client application")
                    }
                    if statusCode == 2122 {
                        HyberLogger.debug("2122,History of messages is disabled for the client")
                    }
                    if statusCode == 2123 {
                        HyberLogger.debug("2123,Bidirectional answer for messages is disabled for the client")
                    }
                    if statusCode == 2132 {
                        HyberLogger.debug("2132,The user credentials used in the request is incorrect")
                    }
                    if statusCode == 2133 {
                        HyberLogger.debug("2133,The access token used in the request is incorrect")
                    }
                    if statusCode == 2134 {
                        HyberLogger.debug("2134,The access token used in the request is expired")
                    }
                    if statusCode == 2135 {
                        HyberLogger.debug("2135,The refresh token used in the request is incorrect or not exists")
                    }
                    if statusCode == 2141 {
                        HyberLogger.debug("2141,Device not found")
                    }
                    if statusCode == 2142 {
                        HyberLogger.debug("2142,Not correct message id")
                    }
                    else {
                        HyberLogger.debug("Unknown Error")
                    }
                }
                
                break
            }
        }
        
    }
    
    public static func refreshAuthToken() -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    {
        
        
        
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": "b5a5b6f4-5af7-11e6-8b77-86f30ca893d3",
            "X-Hyber-IOS-Bundle-Id":"\(kBundleID!)",
            "X-Hyber-Installation-Id": kUUID,
            "X-Hyber-Auth-Token":"4a2a1f73-f714-4b89-b5b1-64d08b54c973"
        ]
        
        Alamofire.request( baseUrlDev + kRefreshToken, method: .post,  encoding: JSONEncoding.default, headers: headers).responseJSON {(response: DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    HyberLogger.debug(response.result.value)
                    
                }
                break
                
            case .failure(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 2100 {
                        HyberLogger.debug("2100, Headers format in api request is wrong")
                    }
                    if statusCode == 2101 {
                        HyberLogger.debug("2101, Json format in api request is wrong")
                    }
                    if statusCode == 2110 {
                        HyberLogger.debug("2101,The client api key used in the request is incorrect")
                    }
                    if statusCode == 2112 {
                        HyberLogger.debug("2112,The iOS Bundle Id used in the request is incorrect")
                    }
                    if statusCode == 2113 {
                        HyberLogger.debug("2113,The Installation Id used in the request is incorrect")
                    }
                    if statusCode == 2120 {
                        HyberLogger.debug("2120,Unspecified error when checking client settings")
                    }
                    if statusCode == 2121 {
                        HyberLogger.debug("2121,Not configured settings for the client application")
                    }
                    if statusCode == 2122 {
                        HyberLogger.debug("2122,History of messages is disabled for the client")
                    }
                    if statusCode == 2123 {
                        HyberLogger.debug("2123,Bidirectional answer for messages is disabled for the client")
                    }
                    if statusCode == 2132 {
                        HyberLogger.debug("2132,The user credentials used in the request is incorrect")
                    }
                    if statusCode == 2133 {
                        HyberLogger.debug("2133,The access token used in the request is incorrect")
                    }
                    if statusCode == 2134 {
                        HyberLogger.debug("2134,The access token used in the request is expired")
                    }
                    if statusCode == 2135 {
                        HyberLogger.debug("2135,The refresh token used in the request is incorrect or not exists")
                    }
                    if statusCode == 2141 {
                        HyberLogger.debug("2141,Device not found")
                    }
                    if statusCode == 2142 {
                        HyberLogger.debug("2142,Not correct message id")
                    }
                    else {
                        HyberLogger.debug("Unknown Error")
                    }
                }
                
                break
            }
        }
        
    }
    
    public static func getDeviceInfo() -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    {
        
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": "b5a5b6f4-5af7-11e6-8b77-86f30ca893d3",
            "X-Hyber-IOS-Bundle-Id":"\(kBundleID!)",
            "X-Hyber-Installation-Id": kUUID,
            "X-Hyber-Auth-Token":"4a2a1f73-f714-4b89-b5b1-64d08b54c973"
        ]
        
        Alamofire.request( baseUrlDev + kGetDeviceInfo, method: .post,  encoding: JSONEncoding.default, headers: headers).responseJSON {(response: DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    HyberLogger.debug(response.result.value)
                    
                }
                break
                
            case .failure(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 2100 {
                        HyberLogger.debug("2100, Headers format in api request is wrong")
                    }
                    if statusCode == 2101 {
                        HyberLogger.debug("2101, Json format in api request is wrong")
                    }
                    if statusCode == 2110 {
                        HyberLogger.debug("2101,The client api key used in the request is incorrect")
                    }
                    if statusCode == 2112 {
                        HyberLogger.debug("2112,The iOS Bundle Id used in the request is incorrect")
                    }
                    if statusCode == 2113 {
                        HyberLogger.debug("2113,The Installation Id used in the request is incorrect")
                    }
                    if statusCode == 2120 {
                        HyberLogger.debug("2120,Unspecified error when checking client settings")
                    }
                    if statusCode == 2121 {
                        HyberLogger.debug("2121,Not configured settings for the client application")
                    }
                    if statusCode == 2122 {
                        HyberLogger.debug("2122,History of messages is disabled for the client")
                    }
                    if statusCode == 2123 {
                        HyberLogger.debug("2123,Bidirectional answer for messages is disabled for the client")
                    }
                    if statusCode == 2132 {
                        HyberLogger.debug("2132,The user credentials used in the request is incorrect")
                    }
                    if statusCode == 2133 {
                        HyberLogger.debug("2133,The access token used in the request is incorrect")
                    }
                    if statusCode == 2134 {
                        HyberLogger.debug("2134,The access token used in the request is expired")
                    }
                    if statusCode == 2135 {
                        HyberLogger.debug("2135,The refresh token used in the request is incorrect or not exists")
                    }
                    if statusCode == 2141 {
                        HyberLogger.debug("2141,Device not found")
                    }
                    if statusCode == 2142 {
                        HyberLogger.debug("2142,Not correct message id")
                    }
                    else {
                        HyberLogger.debug("Unknown Error")
                    }
                }
                
                break
            }
        }
        
    }
    
    public static func getMessageList() -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    {
//       let timestamp = NSDate().timeIntervalSince1970
        var timestamp: TimeInterval{
            return NSDate().timeIntervalSince1970
        }
        
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": "b5a5b6f4-5af7-11e6-8b77-86f30ca893d3",
            "X-Hyber-IOS-Bundle-Id":"\(kBundleID!)",
            "X-Hyber-Installation-Id": kUUID,
            "X-Hyber-Auth-Token":"4a2a1f73-f714-4b89-b5b1-64d08b54c973"
        ]
        let params:Parameters = [
            "startDate":timestamp
        ]
        
        Alamofire.request( baseUrlDev + kGetMsgHistory, method: .post, parameters:params, encoding: JSONEncoding.default, headers: headers).responseJSON {(response: DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    HyberLogger.debug(response.result.value)
                    
                }
                break
                
            case .failure(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 2100 {
                        HyberLogger.debug("2100, Headers format in api request is wrong")
                    }
                    if statusCode == 2101 {
                        HyberLogger.debug("2101, Json format in api request is wrong")
                    }
                    if statusCode == 2110 {
                        HyberLogger.debug("2101,The client api key used in the request is incorrect")
                    }
                    if statusCode == 2112 {
                        HyberLogger.debug("2112,The iOS Bundle Id used in the request is incorrect")
                    }
                    if statusCode == 2113 {
                        HyberLogger.debug("2113,The Installation Id used in the request is incorrect")
                    }
                    if statusCode == 2120 {
                        HyberLogger.debug("2120,Unspecified error when checking client settings")
                    }
                    if statusCode == 2121 {
                        HyberLogger.debug("2121,Not configured settings for the client application")
                    }
                    if statusCode == 2122 {
                        HyberLogger.debug("2122,History of messages is disabled for the client")
                    }
                    if statusCode == 2123 {
                        HyberLogger.debug("2123,Bidirectional answer for messages is disabled for the client")
                    }
                    if statusCode == 2132 {
                        HyberLogger.debug("2132,The user credentials used in the request is incorrect")
                    }
                    if statusCode == 2133 {
                        HyberLogger.debug("2133,The access token used in the request is incorrect")
                    }
                    if statusCode == 2134 {
                        HyberLogger.debug("2134,The access token used in the request is expired")
                    }
                    if statusCode == 2135 {
                        HyberLogger.debug("2135,The refresh token used in the request is incorrect or not exists")
                    }
                    if statusCode == 2141 {
                        HyberLogger.debug("2141,Device not found")
                    }
                    if statusCode == 2142 {
                        HyberLogger.debug("2142,Not correct message id")
                    }
                    else {
                        HyberLogger.debug("Unknown Error")
                    }
                }
                
                break
            }
        }
        
    }

   

    public static func deleteDevice(deviceId: String) -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    {
        
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": "b5a5b6f4-5af7-11e6-8b77-86f30ca893d3",
            "X-Hyber-IOS-Bundle-Id":"\(kBundleID!)",
            "X-Hyber-Installation-Id": kUUID,
            "X-Hyber-Auth-Token":"deb9f874-ba38-4d8d-a3a4-b4465584420b"
        ]
        
        let params:Parameters = [
            "deviceId": deviceId
        ]
        
        Alamofire.request( baseUrlDev + kDeleteDevice, method: .post, parameters:params,  encoding: JSONEncoding.default, headers: headers).responseJSON {(response: DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    HyberLogger.debug(response.result.value)
                    
                }
                break
                
            case .failure(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 2100 {
                        HyberLogger.debug("2100, Headers format in api request is wrong")
                    }
                    if statusCode == 2101 {
                        HyberLogger.debug("2101, Json format in api request is wrong")
                    }
                    if statusCode == 2110 {
                        HyberLogger.debug("2101,The client api key used in the request is incorrect")
                    }
                    if statusCode == 2112 {
                        HyberLogger.debug("2112,The iOS Bundle Id used in the request is incorrect")
                    }
                    if statusCode == 2113 {
                        HyberLogger.debug("2113,The Installation Id used in the request is incorrect")
                    }
                    if statusCode == 2120 {
                        HyberLogger.debug("2120,Unspecified error when checking client settings")
                    }
                    if statusCode == 2121 {
                        HyberLogger.debug("2121,Not configured settings for the client application")
                    }
                    if statusCode == 2122 {
                        HyberLogger.debug("2122,History of messages is disabled for the client")
                    }
                    if statusCode == 2123 {
                        HyberLogger.debug("2123,Bidirectional answer for messages is disabled for the client")
                    }
                    if statusCode == 2132 {
                        HyberLogger.debug("2132,The user credentials used in the request is incorrect")
                    }
                    if statusCode == 2133 {
                        HyberLogger.debug("2133,The access token used in the request is incorrect")
                    }
                    if statusCode == 2134 {
                        HyberLogger.debug("2134,The access token used in the request is expired")
                    }
                    if statusCode == 2135 {
                        HyberLogger.debug("2135,The refresh token used in the request is incorrect or not exists")
                    }
                    if statusCode == 2141 {
                        HyberLogger.debug("2141,Device not found")
                    }
                    if statusCode == 2142 {
                        HyberLogger.debug("2142,Not correct message id")
                    }
                    else {
                        HyberLogger.debug("Unknown Error")
                    }
                }
                
                break
            }
        }


    }
    
    public static func sendMessageCallback(messageId: Int ,message: String?) -> Void //HyberPushNotification?  swiftlint:disable:this line_length
    {
        
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": "b5a5b6f4-5af7-11e6-8b77-86f30ca893d3",
            "X-Hyber-IOS-Bundle-Id":"\(kBundleID!)",
            "X-Hyber-Installation-Id": kUUID,
            "X-Hyber-Auth-Token":"4a2a1f73-f714-4b89-b5b1-64d08b54c973"
        ]

        
        let params: Parameters = [
            "messageId": messageId,
            "answer":message]
        
        Alamofire.request( baseUrlDev + kSendMsgCallback, method: .post, parameters:params,  encoding: JSONEncoding.default, headers: headers).responseJSON {(response: DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    HyberLogger.debug(response.result.value)
                    
                }
                break
                
            case .failure(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 2100 {
                        HyberLogger.debug("2100, Headers format in api request is wrong")
                    }
                    if statusCode == 2101 {
                        HyberLogger.debug("2101, Json format in api request is wrong")
                    }
                    if statusCode == 2110 {
                        HyberLogger.debug("2101,The client api key used in the request is incorrect")
                    }
                    if statusCode == 2112 {
                        HyberLogger.debug("2112,The iOS Bundle Id used in the request is incorrect")
                    }
                    if statusCode == 2113 {
                        HyberLogger.debug("2113,The Installation Id used in the request is incorrect")
                    }
                    if statusCode == 2120 {
                        HyberLogger.debug("2120,Unspecified error when checking client settings")
                    }
                    if statusCode == 2121 {
                        HyberLogger.debug("2121,Not configured settings for the client application")
                    }
                    if statusCode == 2122 {
                        HyberLogger.debug("2122,History of messages is disabled for the client")
                    }
                    if statusCode == 2123 {
                        HyberLogger.debug("2123,Bidirectional answer for messages is disabled for the client")
                    }
                    if statusCode == 2132 {
                        HyberLogger.debug("2132,The user credentials used in the request is incorrect")
                    }
                    if statusCode == 2133 {
                        HyberLogger.debug("2133,The access token used in the request is incorrect")
                    }
                    if statusCode == 2134 {
                        HyberLogger.debug("2134,The access token used in the request is expired")
                    }
                    if statusCode == 2135 {
                        HyberLogger.debug("2135,The refresh token used in the request is incorrect or not exists")
                    }
                    if statusCode == 2141 {
                        HyberLogger.debug("2141,Device not found")
                    }
                    if statusCode == 2142 {
                        HyberLogger.debug("2142,Not correct message id")
                    }
                    else {
                        HyberLogger.debug("Unknown Error")
                    }
                }
                
                break
            }
        }
    
    }
    
}



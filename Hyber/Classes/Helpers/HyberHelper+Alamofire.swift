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
            "X-Hyber-Client-API-Key": kHyberClientAPIKey!,
            "X-Hyber-IOS-Bundle-Id":kBundleID!,
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
               onCompleted: { HyberLogger.debug("Register new subscriber")
            },
               onDisposed:  { HyberLogger.debug("disposed")
            })

    }





    public static func getMessageList(completionHandler: @escaping CompletionHandler) -> Void
    {
        let realm = try! Realm()
        var token: String = realm.objects(Session.self).first!.mToken!
        if token == nil {
            HyberLogger.info("Please reregister user for using SDK")
        } else {
        var date = NSDate()
        var timestamp = UInt64(floor(date.timeIntervalSince1970 * 1000))

        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": kHyberClientAPIKey!,
            "X-Hyber-IOS-Bundle-Id":kBundleID!,
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
               try! realm.write {

                    var results = realm.objects(Message.self).sorted(byProperty: "mDate",  ascending: false)
                    var realmSort = results.value(forKey: "mDate") as! Array<Double>
                    let anotherCorrectSwiftSort = realmSort.sorted{$0 < $1}
                    print(anotherCorrectSwiftSort)
                }

                HyberLogger.debug("Messages loaded")

            }, onError: { let flag = false
                completionHandler(flag)
                Hyber.refreshAuthToken(completionHandler: { (success) -> Void in
                    if success {
                      Networking.getMessagesRequest(parameters: params, headers: headers)
                    }})

                HyberLogger.debug("Error", $0)
            })
        }
    }




    public static func sendMessageCallback(messageId: String ,message: String?, completionHandler: @escaping CompletionHandler) -> Void

    {
        let realm = try! Realm()
        var token: String = realm.objects(Session.self).first!.mToken!
        if token == nil {
            HyberLogger.info("Please reregister user for using SDK")
        } else {
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": kHyberClientAPIKey!,
            "X-Hyber-IOS-Bundle-Id":kBundleID!,
            "X-Hyber-Installation-Id": kUUID,
            "X-Hyber-Auth-Token": token,
            "sdkVersion":"2.1.0"
        ]
        let params: [String: Any] = [
            "messageId": messageId,
            "text":message!]

            let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data

            let decoded = try! JSONSerialization.jsonObject(with: jsonData, options: [])
            // here "decoded" is of type `Any`, decoded from JSON data

            // you can now cast it with the right type
            if let dictFromJSON = decoded as? NSArray {
                // use dictFromJSON
                print(dictFromJSON)
            }


        Networking.sentBiderectionalMessage(parameters: decoded as! [String : Any], headers: headers)
            .subscribe(onNext: {json in
                let json = JSON(json)
                let flag = true
                completionHandler(flag)
            },
            onError: { HyberLogger.debug("Error", $0)
                let flag = false
                completionHandler(flag)
                Hyber.refreshAuthToken(completionHandler: { (success) -> Void in
                    if success {
                     Networking.sentBiderectionalMessage(parameters: decoded as! [String : Any], headers: headers)
                    }})
            },
              onCompleted: {
                let flag = true
                completionHandler(flag)
                HyberLogger.debug("Message sented")
            })
    }

    }


}

extension Hyber{


    static func updateDevice()  -> Void
    {
        let disposeBag = DisposeBag()

        let realm = try! Realm()
        var token: String = realm.objects(Session.self).first!.mToken!
            if token == nil {
            HyberLogger.info("Please reregister user for using SDK")
            } else {

        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": kHyberClientAPIKey!,
            "X-Hyber-IOS-Bundle-Id":kBundleID!,
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
            },onError: { HyberLogger.debug("Error", $0)
                Hyber.refreshAuthToken(completionHandler: { (success) -> Void in
                    if success {
                         Networking.updateDeviceRequest(parameters: phoneData, headers: headers)
                    }})
            },
              onCompleted: { HyberLogger.debug("Device updated")
            })
        }
    }


    static func refreshAuthToken( completionHandler: @escaping CompletionHandler) -> Void
    {
        let realm = try! Realm()
        var token: String = realm.objects(Session.self).first!.mToken!
        var refreshToken: String = realm.objects(Session.self).first!.mRefreshToken!
        if token == nil {
            HyberLogger.info("Please reregister user for using SDK")
        } else {
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": kHyberClientAPIKey!,
            "X-Hyber-IOS-Bundle-Id":kBundleID!,
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
                let flag = true
                completionHandler(flag)
            },
              onError: { HyberLogger.debug("Error", $0)
                let flag = false
                completionHandler(flag)
            },
              onCompleted: {
                HyberLogger.debug("Token refreshed. Try again")
                let flag = true
                completionHandler(flag)
            })
        }
    }


    static func sentDeliveredStatus(messageId: String?) -> Void
    {
        let realm = try! Realm()
        var token: String = realm.objects(Session.self).first!.mToken!
        if token == nil {
            HyberLogger.info("Please reregister user for using SDK")
        } else {
            var date = NSDate()
            var timestamp = UInt64(floor(date.timeIntervalSince1970 * 1000))
            
            let authToken = Session()
            let headers = [
                "Content-Type": "application/json",
                "X-Hyber-Client-API-Key": kHyberClientAPIKey!,
                "X-Hyber-IOS-Bundle-Id":kBundleID!,
                "X-Hyber-Installation-Id": kUUID,
                "X-Hyber-Auth-Token": token,
                "sdkVersion":"2.1.0"
            ]
            
            
            let params:[String: Any] = [
                "messageId": messageId!,
                "receivedAt": timestamp
                ] as [String : Any]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            let decoded = try! JSONSerialization.jsonObject(with: jsonData, options:[])
            
            if let dictFromJSON = decoded as? [String:String] {
            }
            
            HyberLogger.debug("JSON", decoded)
            Networking.sentDeliveredStatus(parameters: decoded as! [String : Any], headers: headers)
                .subscribe(onNext: { _ in
                    let updateStatus = Message(value: ["messageId": messageId!, "isReported": true, "mDate": timestamp])
                    try! realm.write {
                        realm.create(Message.self, value: ["messageId": messageId!, "isReported": true, "mDate": timestamp], update: true)
                        
                    }
                },
                onError: { print("Error", $0)
                    Hyber.refreshAuthToken(completionHandler: { (success) -> Void in
                        if success {
                            Networking.sentDeliveredStatus(parameters: decoded as! [String : Any], headers: headers)
                        }})
                },
                           onCompleted: {
                            
                })
           
            
        }
    }
    /*** Next API release**/

    static func deleteDevice(deviceId: String) -> Void
    {
        let realm = try! Realm()
        var token: String = realm.objects(Session.self).first!.mToken!
            if token == nil {
            HyberLogger.info("Please reregister user for using SDK")
            } else {
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": kHyberClientAPIKey!,
            "X-Hyber-IOS-Bundle-Id":kBundleID!,
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
            },
                onError: { HyberLogger.debug("Error", $0)
                    Hyber.refreshAuthToken(completionHandler: { (success) -> Void in
                        if success {
                           Networking.deleteDevice(parameters: params, headers: headers)
                        }})

            })
        }
    }


    static func getDeviceInfo() -> Void {
        let realm = try! Realm()
        var token: String = realm.objects(Session.self).first!.mToken!
            if token == nil {
                HyberLogger.info("Please reregister user for using SDK")
            } else {
        let headers = [
            "Content-Type": "application/json",
            "X-Hyber-Client-API-Key": kHyberClientAPIKey!,
            "X-Hyber-IOS-Bundle-Id":kBundleID!,
            "X-Hyber-Installation-Id": kUUID,
            "X-Hyber-Auth-Token": token,
            "sdkVersion":"2.1.0"
        ]
        print(headers)

        Networking.getDeviceInfoRequest(parameters: nil, headers: headers)
            .subscribe(onNext: { json in
                let json = JSON(json)
                print(json)
                
            },
                onError: { HyberLogger.debug("Error", $0)
                    Hyber.refreshAuthToken(completionHandler: { (success) -> Void in
                        if success {
                           Networking.getDeviceInfoRequest(parameters: nil, headers: headers)
                        }})
            })
    }
    }

}

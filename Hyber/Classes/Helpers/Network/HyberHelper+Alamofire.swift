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
import RxSwift
import CryptoSwift


public extension Hyber {

    typealias CompletionHandler = (_ success: Bool) -> Void
    
    static let disposeBag = DisposeBag()
    static let standart =  UserDefaults.standard
    
    public static func registration(phoneId: String, password: String, completionHandler: @escaping CompletionHandler) {
        var currentTime = Int64(Date().timeIntervalSince1970 * 1000)
        var lastAuthTime = standart.integer(forKey: "authTime") ?? 0
        if (currentTime - lastAuthTime) <= 1000 {
            HyberLogger.error("Too mutch requests per second")
            return
        } else {
           standart.set(currentTime, forKey: "authTime")
        }
        
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
            "sdkVersion": "2.2.2"
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
            .addDisposableTo(disposeBag)
    }
    
    public static func getMessageList(completionHandler: @escaping CompletionHandler) -> Void {
        do {
            let realm = try Realm()
            if realm.objects(User.self).first?.mPhone == nil {
                let flag = false
                completionHandler(flag)
                HyberLogger.info("Please register user session")
            } else {
                let date = NSDate()
                let timestamp = UInt64(floor(date.timeIntervalSince1970 * 1000))
                let parameters : Parameters = [
                    "startDate": timestamp
                ]
                Networking.getMessagesRequest(parameters: parameters, headers: Headers.getHeaders())
                    .subscribe(onNext: { _ in
                        let flag = true
                        completionHandler(flag)
                        HyberLogger.debug("Messages loaded")
                        
                    }, onError: { let flag = false
                        completionHandler(flag)
                        HyberLogger.info("Error", $0)
                    })
                    .addDisposableTo(disposeBag)
            }
        } catch _ {
            HyberLogger.error(Error.self)
        }
    }
    
    public static func sendMessageCallback(messageId: String, message: String?, completionHandler: @escaping CompletionHandler) -> Void {
        do {
            let realm = try Realm()
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
                let params: Parameters = [
                    "messageId": messageId,
                    "answer": message!
                ]
                
                let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
                
                Networking.sentBiderectionalMessage(parameters: decoded as! [String: AnyObject], headers: Headers.getHeaders())
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
                    .addDisposableTo(disposeBag)
            }
        } catch _ {
            HyberLogger.error(Error.self)
        }
    }
    
    public static func revokeDevice(deviceId: NSArray, completionHandler: @escaping CompletionHandler) -> Void {
        do {
            let realm = try Realm()
            if realm.objects(User.self).first?.mPhone == nil {
                let flag = false
                completionHandler(flag)
                HyberLogger.info("Please register user session")
            } else {
                let params: [String: AnyObject] = [
                    "devices": deviceId
                ]
                let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
                
                Networking.deleteDevice(parameters: decoded as! [String: AnyObject], headers: Headers.getHeaders() )
                    .subscribe(onNext: { _ in
                        let flag = true
                        completionHandler(flag)
                    },
                               onError: { HyberLogger.info("Error", $0)
                                let flag = false
                                completionHandler(flag)
                    })
                    .addDisposableTo(disposeBag)
            }
        } catch _ {
            HyberLogger.error(Error.self)
        }
    }
    
    public static func getDeviceList(completionHandler: @escaping CompletionHandler) -> Void {
        do {
            let realm = try Realm()
            if realm.objects(User.self).first?.mPhone == nil {
                let flag = false
                completionHandler(flag)
                HyberLogger.info("Please register user session")
            } else {
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(realm.objects(Device.self))
                }
                Networking.getDeviceInfoRequest(parameters: nil, headers: Headers.getHeaders())
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
                    .addDisposableTo(disposeBag)

            }
        } catch _ {
            HyberLogger.error(Error.self)
        }
    }
    
    //Network handler
    
    public static func fetchMessageArea(completionHandler: @escaping (AnyObject?, Error?) -> ()) {
        do {
            let realm = try Realm()
            if realm.objects(User.self).first?.mPhone == nil {
                HyberLogger.info("Please register user session")
            } else {
                let date = NSDate()
                let timestamp = UInt64(floor(date.timeIntervalSince1970 * 1000))
                let parameters : Parameters = [
                    "startDate": timestamp
                ]
                Networking.getMessagesArea(parameters: parameters, headers: Headers.getHeaders(), completionHandler: completionHandler)
            }
            
        } catch _ {
            HyberLogger.error(Error.self)
        }
    }
    
    public static func fetchDeviceList(completionHandler: @escaping (AnyObject?, Error?) -> ()) {
        do {
            let realm = try Realm()
            if realm.objects(User.self).first?.mPhone == nil {
                HyberLogger.info("Please register user session")
            } else {
                Networking.getDeviceArea(parameters: nil, headers: Headers.getHeaders(), completionHandler: completionHandler)
            }
            
        } catch _ {
            HyberLogger.error(Error.self)
        }
    }
    
    
}

extension Hyber {
    
    static func updateDevice() -> Void {
        do {
            let realm = try Realm()
            if realm.objects(User.self).first?.mPhone == nil {
                HyberLogger.info("Please register user session")
            } else {
                guard let fcmToken = kFCM else { return}
                let phoneData: Parameters = [
                    "fcmToken": fcmToken,
                    "osType": kOSType,
                    "osVersion": kOSVersion,
                    "deviceType": kDeviceType,
                    "deviceName": kDeviceName,
                    "sdkVersion": "2.2.2"
                ]
                
                HyberLogger.info("Phone info:\(phoneData)")
                
                Networking.updateDeviceRequest(parameters: phoneData, headers: Headers.getHeaders())
                    .subscribe(onNext: { _ in
                    }, onError: { HyberLogger.info("Error", $0)
                    }, onCompleted: { HyberLogger.info("Device updated")})
                    .addDisposableTo(disposeBag)

            }
            
        } catch _ {
            HyberLogger.error(Error.self)
        }
    }
    
    static func sentDeliveredStatus(messageId: String?) -> Void {
        do {
            let realm = try Realm()
            if realm.objects(User.self).first?.mPhone == nil {
                HyberLogger.info("Please register user session")
            } else {
                let date = NSDate()
                let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss' 'Z"
                let dateString: String = dateFormatter.string(from: date as Date)
                let params: Parameters = [
                    "messageId": messageId!,
                    "receivedAt": dateString
                ]
                
                let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
                
                Networking.sentDeliveredStatus(parameters: decoded as! [String: AnyObject], headers: Headers.getHeaders() )
                    .subscribe(onNext: { _ in
                        let utc = date.toString()
                        try! realm.write {
                            realm.create(Message.self, value: ["messageId": messageId!, "isReported": true, "mDate": "\(utc)"], update: true)
                        }
                        HyberLogger.info("Delivered report")
                    }, onError: { HyberLogger.info("Error", $0)})
                    .addDisposableTo(disposeBag)
            }
            
        } catch _ {
            HyberLogger.error(Error.self)
        }
    }
    
    
}

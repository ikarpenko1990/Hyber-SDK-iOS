//
//  HyberRealmData.swift
//  Pods
//  
//  Created by Taras on 10/25/16.
//
//

import UIKit
import RealmSwift
import SwiftyJSON

class DataRealm {
    
   static func session(uuid: String) -> Void {
    do {
        let sessionId = uuid
        let newSession = Session()
            newSession.mSessionToken = sessionId
            newSession.mToken = "session"
            newSession.mUserId = "current"
        let realm = try Realm()
        
        try realm.write {
             realm.add(newSession, update: true)
        }
        } catch _ {
            HyberLogger.error(Error.self)
        }

    }
    
    static func saveProfile(json: JSON) -> Void {
        do {
        let session = json["session"]
        let profile = json["profile"]
        let user = User()
            user.mPhone = profile["userPhone"].string
        let newSession = Session()
            newSession.mToken = session["token"].string!
            newSession.mUser = user
            newSession.mUserId = profile["userId"].string
        let realm = try Realm()
        try realm.write {
            realm.add(newSession, update: true)
            realm.add(user, update: true)
            HyberLogger.info("Data Saved")
        }
        } catch _ {
            HyberLogger.error(Error.self)
        }

    }

    static func updateDevice(json: JSON) -> Void {
        do {
        let realm = try Realm()
        try realm.write {
             realm.create(Device.self, value: ["deviceId": json["deviceId"].string!, "isActive": true], update: true)
        }
        } catch _ {
            HyberLogger.error(Error.self)
        }
    }
    
    static func saveMessages(json: JSON) -> Void {
        let message = json["messages"].arrayObject
        do {
        let realm = try Realm()
        let messages = List<Message>()
        HyberLogger.info(message!)
        if let jsonArray = message as? [[String: AnyObject]] {
            for messagesArray in jsonArray {
                let newMessages = Message()
                    newMessages.mId = messagesArray["phone"] as? String
                    newMessages.messageId = messagesArray["messageId"] as? String
                    newMessages.mTitle = messagesArray["title"] as? String
                    newMessages.mPartner = messagesArray["partner"] as? String
                    newMessages.mBody = messagesArray["body"] as? String
                    newMessages.mDate = messagesArray["time"] as? String
                    newMessages.isReported = true
                
                if messagesArray["button"] != nil {
                    if let optionsArray = messagesArray["button"] as? [String: AnyObject] {
                        newMessages.mButtonUrl = optionsArray["url"] as? String
                        newMessages.mButtonText = optionsArray["text"] as? String
                    }
                }
               
                if messagesArray["image"] != nil {
                    if let imageArray = messagesArray["image"] as? [String:AnyObject] {
                        newMessages.mImageUrl = imageArray["url"] as? String
                    }
                }
                
                messages.append(newMessages)
                
                try realm.write {
                    realm.add(newMessages, update: true)
                }
            }
         
            }
        } catch _ {
            HyberLogger.error(Error.self)
        }
    }
    
    static func saveDeiveList(json: JSON) -> Void {
        let rawArray = json["devices"].rawValue
        do {
        
        let realm = try Realm()
        let deviceList = List<Device>()
        
        if let jsonArray = rawArray as? [[String: Any]] {
            for deviceArray in jsonArray {
                let newDevice = Device()
                
                newDevice.deviceId = deviceArray["id"] as? String
                newDevice.osType = deviceArray["osType"] as? String
                newDevice.osVersion = deviceArray["osVersion"] as? String
                newDevice.deviceType = deviceArray["deviceType"] as? String
                newDevice.deviceName = deviceArray["deviceName"] as? String
                newDevice.createdAt = deviceArray["createdAt"] as? String
                newDevice.updatedAt = deviceArray["updatedAt"] as? String
                
                deviceList.append(newDevice)
                try realm.write {
                    realm.add(newDevice, update: true)
                }
            }
        }
        
        } catch _ {
            HyberLogger.error(Error.self)
        }
    }
    
    static func saveNotification(json: JSON, message: JSON) -> Void {
        do {
        let realm = try! Realm()
        let messages = List<Message>()
        let newMessages = Message()
        newMessages.messageId = json["messageId"].rawString()
        newMessages.mTitle = message["title"].string
        newMessages.mPartner = "push"
        newMessages.mBody = message["body"].string
        if let imageArray = json["image"].rawValue as? [String: AnyObject] {
            if imageArray["url"] is NSNull {
                HyberLogger.info("Image:Null")
            } else {
                newMessages.mImageUrl = imageArray["url"] as! String?
            }
        }
        
        if json["button"] != nil {
            if let optionsArray = json["button"].rawValue as? [String: AnyObject] {
                if optionsArray["text"] is NSNull {
                    HyberLogger.info("Action:Null")
                } else {
                    newMessages.mButtonUrl = optionsArray["text"] as! String?
                }
                
                if optionsArray["url"] is NSNull {
                    HyberLogger.info("Caption:Null")
                } else {
                    newMessages.mButtonText = optionsArray["url"] as! String?
                }
            }
        }
        
        messages.append(newMessages)
        try realm.write {
            realm.add(newMessages, update: true)
        }
            
    } catch _ {
        HyberLogger.error(Error.self)
    }
    
    }

    
    class func responseError(error: JSON) {
        HyberLogger.error(error)
    }
    
    
    
}


extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
    return array
    }
    
    
}




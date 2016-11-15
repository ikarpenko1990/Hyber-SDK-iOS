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

class RealmData {
    
  public  static let urealm : Realm = {
        return try! Realm()
    }()
   
    func setDefaultRealmForUser(username: String) {
        var config = Realm.Configuration()
        
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("\(username).realm")
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    func createUpdateUser(rUser: User)  {
            do {
                
                try RealmData.urealm.write {
                    RealmData.urealm.add(rUser)
                HyberLogger.info("UserData saved!")
                }
                
            } catch let error as NSError {
                HyberLogger.error("Error creating Listing DB: \(error.userInfo)")
            }
        
    }
    
    
    
    public func fetchMessages (messages: [String:AnyObject]) {
        
        
        do {
            let newMessages = Message()
            newMessages.mUser = User()
            newMessages.mId = messages["messageId"]?.string
            newMessages.mTitle = messages["from"]?.string
            newMessages.mBody = messages["text"]?.string
            newMessages.mDate = messages["date"]?.string
            newMessages.mButtonText = messages["caption"]?.string
            newMessages.mButtonUrl = messages["action"]?.string
            newMessages.mImageUrl = messages["img"]?.string
            newMessages.isRead = false
            newMessages.isReported = false

            try RealmData.urealm.write {
                RealmData.urealm.add(newMessages, update: true)
                    HyberLogger.info("UserData saved!")
            }
            
        } catch {
            HyberLogger.info("Message fetching error: \(error)")
        }
        
    }
    
    public func saveSession(sessionData newSession: [String:AnyObject]?) {
        do{
            let session = Session()
            session.mToken = newSession?["authToken"]?.string
            session.mRefreshToken = newSession?["refreshToken"]?.string
            session.mExpirationDate = newSession?["expirationDate"]?.string
            session.mExpired = false
            
            try RealmData.urealm.write {
                RealmData.urealm.add(session, update: true)
            }
        }
        catch let err as NSError {
             HyberLogger.debug("Message list: " + err.localizedDescription)
        }
    
    }
    
    public func saveDeviceinfo(saveToken: String ) {
        let device = Device()
        device.modelName = kDeviceName
        device.installationId = kUUID
        device.osType = kOSType
        device.deviceType = kDeviceType
        device.deviceName = kDeviceName
        device.fcmToken = saveToken
        let realm = try! Realm()
        try! realm.write {
            realm.add(device , update: true)
        }
    }

    
    //reading methods
    public func getMessageList() ->Results<Message> {
        return RealmData.urealm.objects(Message)
    }
    
    public func getUsers() -> Results<User> {
        return RealmData.urealm.objects(User)
    }
    
}

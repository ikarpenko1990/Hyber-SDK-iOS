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
   
     func saveSession(sessionData newSession: [String:AnyObject]?) {
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
    
     func saveDeviceinfo(saveToken: String ) {
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




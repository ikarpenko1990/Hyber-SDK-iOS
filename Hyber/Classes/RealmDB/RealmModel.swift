import Foundation
import RealmSwift
import ObjectMapper


public class Message: Object, Mappable {
  dynamic var mId: String?
  dynamic var messageId: String?
  dynamic var mUser: User?
  dynamic var mPartner: String?
  dynamic var mTitle: String?
  dynamic var mBody: String?
  dynamic var mDate:  String?
  dynamic var mImageUrl: String?
  dynamic var mButtonUrl: String?
  dynamic var mButtonText: String?
  dynamic var isRead = false
  dynamic var isReported = false

  override public static func primaryKey() -> String? {
    return "messageId"
  }
    
    convenience required public init?(map: Map) {
        self.init()
        
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        messageId <- map["messageId"]
        mPartner <- map["partner"]
        mTitle <- map["from"]
        mBody <- map["text"]
        mDate <- map["drTime"]
        mButtonUrl <- map["action"]
        mButtonText <- map["caption"]
        isReported <- map["drTime"]
        mUser <- map["to"]
        mImageUrl <- map["img"]

    }

}

class Session: Object, Mappable {
  dynamic var mUserId: String?
  dynamic var mUser: User?
  dynamic var mToken: String? = nil
  dynamic var mRefreshToken: String?
  dynamic var mExpirationDate: String?
  dynamic var mExpired = false
    
    override static func primaryKey() -> String? {
    return "mUserId"
  }

  override static func indexedProperties() -> [String] {
    return [
        "mToken",
      "mRefreshToken",
    ]
  }
    
    convenience required init?(map: Map) {
        self.init()
        mapping(map: map)
    }
    

    
    func mapping(map: Map) {
        mUserId <- map["userPhone"]
        mToken <- map["authToken"]
        mRefreshToken <- map["refreshToken"]
        mExpirationDate <- map["expirationDate"]

    }

}

class User: Object, Mappable {
  dynamic var mId: String?
  dynamic var mPhone: String?
  dynamic var isActive = false

  override static func primaryKey() -> String? {
    return "mPhone"
  }

  override static func indexedProperties() -> [String] {
    return [
      "mPhone","mId"
    ]
  }
    
    convenience required init?(map: Map) {
        self.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        mId <- map["userId"]
        mPhone <- map["userPhone"]      
        
        
    }
 
}


public class Device: Object, Mappable {
    
    dynamic var installationId: String?
    dynamic var osType: String?
    dynamic var fcmToken: String?
    dynamic var osVersion: String?
    dynamic var deviceType: String?
    dynamic var deviceName: String?
    dynamic var modelName: String?
    dynamic var createdAt: String?
    dynamic var updatedAt: String?
    dynamic var deviceId: String?
    dynamic var userId: String?
    dynamic var isActive = false
    
  public override static func primaryKey() -> String? {
        return "deviceId"
    }
        
  public  convenience required init?(map: Map) {
        self.init()
        mapping(map: map)
    }
    
   public func mapping(map: Map) {
        deviceId              <- map["deviceId"]
        installationId        <- map["installId"]
        fcmToken              <- map["fcmTken"]
        osType                <- map["osType"]
        osVersion             <- map["osVersion"]
        deviceType            <- map["deviceType"]
        deviceName            <- map["devicaName"]
        modelName             <- map["modelName"]
        createdAt             <- map["createdAt"]
        updatedAt             <- map["updatedAt"]

    }
    
}

import Foundation
import RealmSwift


public class Message: Object {
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
}

class Session: Object {
  dynamic var mUserId: String?
  dynamic var mUser: User?
  dynamic var mToken:String?
  dynamic var mSessionToken: String?
    
    override static func primaryKey() -> String? {
    return "mUserId"
  }

  override static func indexedProperties() -> [String] {
    return [
        "mToken",
      "mSessionToken",
    ]
  }
}

class User: Object {
  dynamic var mId: String?
  dynamic var mPhone: String? = ""
  dynamic var isActive = false

  override static func primaryKey() -> String? {
    return "mPhone"
  }

  override static func indexedProperties() -> [String] {
    return [
      "mPhone","mId"
    ]
  }
}


public class Device: Object {
    
    dynamic var osType: String?
    dynamic var osVersion: String?
    dynamic var deviceType: String?
    dynamic var deviceName: String?
    dynamic var modelName: String?
    dynamic var createdAt: String?
    dynamic var updatedAt: String?
    dynamic var deviceId: String?
    dynamic var isActive = false
    
  public override static func primaryKey() -> String? {
        return "deviceId"
    }
}

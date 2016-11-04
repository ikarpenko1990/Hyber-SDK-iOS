import Foundation
import RealmSwift
import ObjectMapper

class Message: Object, Mappable {
  dynamic var mId: String?
  dynamic var messageId: String?
  dynamic var mUser: User?
  dynamic var mPartner: String?
  dynamic var mTitle: String?
  dynamic var mBody: String?
  dynamic var mDate: String?
  dynamic var mImageUrl: String?
  dynamic var mButtonUrl: String?
  dynamic var mButtonText: String?
  var isRead = false
  dynamic var isReported = false

  override static func primaryKey() -> String? {
    return "mId"
  }
    
    convenience required init?(map: Map) {
        self.init()
        
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        messageId <- map["messageId"]
        mPartner <- map["userPhone"]
        mTitle <- map["title"]
        mBody <- map["body"]
        mDate <- map["time"]
        mImageUrl <- map["url"]
        mButtonUrl <- map["url"]
        mButtonText <- map["text"]
      


    }
    


}

class Generic<T: NSObject> {
    func create() -> T {
        return T()
    }
}

class Session: Object, Mappable {
  dynamic var mUserId: String?
  dynamic var mUser: User?
  dynamic var mToken: String?
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
        mUserId <- map["userId"]
        mToken <- map["userPhone"]
        mRefreshToken <- map["createdAt"]
        mExpirationDate <- map["createdAt"]
        mExpired <- map["createdAt"]

        
    }

}

class User: Object, Mappable {
  dynamic var mId: String?
  dynamic var mPhone = 0
  dynamic var isActive = false

  override static func primaryKey() -> String? {
    return "mId"
  }

  override static func indexedProperties() -> [String] {
    return [
      "mPhone",
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


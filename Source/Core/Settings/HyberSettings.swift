//
//  HyberSettings.swift
//  Hyber
//
//  Created by Vitalii Budnik on 12/10/15.
//  Copyright © 2015 Global Messages Services Worldwide. All rights reserved.
//

import Foundation
import CoreData

/**
 Settings of `Hyber` framework
*/
internal class HyberSettings: NSObject {
  
  /// Current user. Private
	private var _user: HyberSubscriber? = .None
  
  /// Current subscriber information
  var user: HyberSubscriber? {
    set {
      if _user != newValue {
        _user = newValue
        save()
      }
    }
    get {
      if let user_ = _user {
        return user_
      } else {
//        _user = HyberSubscriber(phone: .None, withEmail: .None)
        return .None
      }
    }
  }
  
  /// Apple push-notification device token, represented as `String`
	var apnsToken: String? {
		didSet {
      if apnsToken != oldValue {
        save()
      }
    }
	}
  
  /// Google Cloud Messaging device token
	var gcmToken: String? {
		didSet {
      hyberLog.info("gcmToken=\(gcmToken)")
      if gcmToken != oldValue {
        save()
        let gcmToken = self.gcmToken
        Hyber.updateGCMToken(gcmToken)
      }
    }
	}
  
  /// Global Message Services device token
	var gmsToken: UInt64 {
		didSet {
      if gmsToken != oldValue {
        save()
      }
    }
	}
  
  /// Flag indicates if subscriber athorized or not
	var authorized: Bool {
		didSet {
      if authorized != oldValue {
        save()
        
        Hyber.allowRecievePush(gcmToken != .None && authorized)
        
      }
    }
	}
  
  // Private initializer
	private override init() {
		//user = .None
		gcmToken = .None
		apnsToken = .None
		gmsToken = 0
    authorized = false
		super.init()
	}
  
	// MARK: NSCoding
  
  /**
   Saves current setting to file.
   */
	internal func save() {
		guard let settingsFileURLpath = HyberSettings.filePath else { return }
		if !NSKeyedArchiver.archiveRootObject(self, toFile: settingsFileURLpath) {
			hyberLog.error("can't save settings to file")
		}
	}

  /**
   Sign outs current user and cleares all fetched data.
   - Returns: `true` if sign out successful, `false` otherwise
   */
	func signOut() -> Bool {
    
    user = .None
    authorized = false
    
    let errorOccurred: Bool
    let eraseDataResult = HyberCoreDataHelper.managedObjectContext
      .deleteObjectctsOfAllEntities()
    switch eraseDataResult {
    case .Failure(_):
      errorOccurred = true
    default:
      errorOccurred = false
    }
    
    return !errorOccurred
    
	}
	
  override var description: String {
		return "apnsToken: \(apnsToken)\ngcmToken: \(gcmToken)\ngmsToken: \(gmsToken)\nuser: \(user)"
	}
	
  // MARK: NSCoding
  @objc required init?(coder aDecoder: NSCoder) { // swiftlint:disable:this missing_docs
    
    let gmsTokenNumber = aDecoder.decodeObjectForKey("gmsToken") as? NSNumber
    
    _user      = HyberSubscriber(
      withDictionary: aDecoder.decodeObjectForKey("user") as? [String: AnyObject])
    
    apnsToken  = aDecoder.decodeObjectForKey("apnsToken") as? String
    gcmToken   = aDecoder.decodeObjectForKey("gcmToken")  as? String
    gmsToken   = gmsTokenNumber?.unsignedLongLongValue ?? 0
    authorized = aDecoder.decodeBoolForKey  ("authorized")
    
  }
  
  @objc func encodeWithCoder(aCoder: NSCoder) { // swiftlint:disable:this missing_docs
    if let userDict = user?.asDictionary() {
      aCoder.encodeObject(userDict, forKey: "user")
    }
    
    let gmsTokenNumber = NSNumber(unsignedLongLong: gmsToken)
    
    // swiftlint:disable comma
    aCoder.encodeObject(gcmToken,       forKey: "gcmToken")
    aCoder.encodeObject(apnsToken,      forKey: "apnsToken")
    aCoder.encodeObject(gmsTokenNumber, forKey: "gmsToken")
    aCoder.encodeBool  (authorized,     forKey: "authorized")
    // swiftlint:enable comma
    
  }
 
  /**
   Shared instance of current settings
   */
  internal static var currentSettings: HyberSettings = {
    if let settingsFilePath = filePath
      where NSFileManager.defaultManager().fileExistsAtPath(settingsFilePath) // swiftlint:disable:this line_length
    {
      if let settings = NSKeyedUnarchiver
        .unarchiveObjectWithFile(settingsFilePath) as? HyberSettings // swiftlint:disable:this line_length
      {
        return settings
      }
    }
    return HyberSettings()
    
  }()
  
  /**
   Settings filepath
   */
  private static var filePath: String? = {
    return NSFileManager.libraryDirectoryURL?.URLByAppendingPathComponent("hyberConfig.plist").path
  }()
  
  
}

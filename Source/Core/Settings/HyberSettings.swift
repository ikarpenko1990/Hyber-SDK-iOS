//
//  HyberSettings.swift
//  Hyber
//
//  Created by Vitalii Budnik on 12/10/15.
//  Copyright © 2015 Global Messages Services Worldwide. All rights reserved.
//

import Foundation
import CoreData
import UIKit

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
			hyberLog.verbose("apnsToken: \(apnsToken)")
      if apnsToken != oldValue {
        save()
      }
    }
	}
  
  /// Firebase Messaging device token
	var firebaseMessagingToken: String? {
		didSet {
      hyberLog.verbose("firebaseMessagingToken: \(firebaseMessagingToken)")
      if firebaseMessagingToken != oldValue {
        save()
      }
    }
	}
  
  /// Global Message Services device token
	var hyberDeviceId: UInt64 {
		didSet {
			hyberLog.verbose("hyberDeviceId: \(hyberDeviceId)")
      if hyberDeviceId != oldValue {
        save()
      }
    }
	}
  
  /// Flag indicates if subscriber athorized or not
	var authorized: Bool {
		didSet {
			hyberLog.verbose("authorized: \(authorized)")
      if authorized != oldValue {
        save()
        
        Hyber.allowRecievePush(firebaseMessagingToken != .None && authorized)
        
      }
    }
	}
  
  // Private initializer
	private override init() {
		//user = .None
		firebaseMessagingToken = .None
		apnsToken = .None
		hyberDeviceId = 0
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
    hyberDeviceId = 0
		
    let errorOccurred: Bool
    let eraseDataResult = HyberCoreDataHelper.managedObjectContext
      .deleteObjectctsOfAllEntities()
    switch eraseDataResult {
    case .Failure(_):
      errorOccurred = true
    default:
      errorOccurred = false
    }
		
		NSNotificationCenter.defaultCenter().postNotificationName(kHyberDidSignOut, object: self)
		
    return !errorOccurred
    
	}
	
  override var description: String {
		return "apnsToken: \(apnsToken)\nfirebaseMessagingToken: \(firebaseMessagingToken)\nhyberDeviceId: \(hyberDeviceId)\nuser: \(user)"
	}
	
  // MARK: NSCoding
  @objc required init?(coder aDecoder: NSCoder) { // swiftlint:disable:this missing_docs
    
    let hyberDeviceIdNumber = aDecoder.decodeObjectForKey("hyberDeviceId") as? NSNumber
    
    _user                  = HyberSubscriber(
      withDictionary: aDecoder.decodeObjectForKey("user") as? [String: AnyObject])
    
		apnsToken              = aDecoder.decodeObjectForKey("apnsToken") as? String
    firebaseMessagingToken = aDecoder.decodeObjectForKey("firebaseMessagingToken")  as? String
    hyberDeviceId          = hyberDeviceIdNumber?.unsignedLongLongValue ?? 0
    authorized             = aDecoder.decodeBoolForKey  ("authorized")
  }
  
  @objc func encodeWithCoder(aCoder: NSCoder) { // swiftlint:disable:this missing_docs
    if let userDict = user?.asDictionary() {
      aCoder.encodeObject(userDict, forKey: "user")
    }
    
    let hyberDeviceIdNumber = NSNumber(unsignedLongLong: hyberDeviceId)
    
    // swiftlint:disable comma
		aCoder.encodeObject (firebaseMessagingToken,          forKey: "firebaseMessagingToken")
    aCoder.encodeObject (apnsToken,                       forKey: "apnsToken")
    aCoder.encodeObject (hyberDeviceIdNumber,             forKey: "hyberDeviceId")
    aCoder.encodeBool   (authorized,                      forKey: "authorized")
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
    return NSFileManager.libraryDirectoryURL?.URLByAppendingPathComponent("hyberConfig.plist")!.path
  }()
	
	/**
		Console log level.
		Default: `.Info`
	*/
	var consoleLogLevel: HyberXCGLoggerLogLevel = .Info {
		didSet {
			
			hyberLog.verbose("consoleLogLevel: \(consoleLogLevel)")
			
			hyberLog.removeLogDestination(XCGLogger.Constants.baseConsoleLogDestinationIdentifier)
			
			let standardConsoleLogDestination: XCGConsoleLogDestination = XCGConsoleLogDestination(owner: hyberLog, identifier: XCGLogger.Constants.baseConsoleLogDestinationIdentifier)
			
			standardConsoleLogDestination.showLogIdentifier = false
			standardConsoleLogDestination.showFunctionName = true
			standardConsoleLogDestination.showThreadName = true
			standardConsoleLogDestination.showLogLevel = true
			standardConsoleLogDestination.showFileName = true
			standardConsoleLogDestination.showLineNumber = true
			standardConsoleLogDestination.showDate = false
			standardConsoleLogDestination.outputLogLevel = fileLogLevel
			
			standardConsoleLogDestination.xcodeColors = consoleLogColors
			
			hyberLog.addLogDestination(standardConsoleLogDestination)
			
		}
	}
	
	/**
		File log level
		Default: `.Verbose`
	*/
	var fileLogLevel: HyberXCGLoggerLogLevel = .Verbose {
		didSet {
			
			hyberLog.verbose("fileLogLevel: \(fileLogLevel)")
			
			hyberLog.removeLogDestination(XCGLogger.Constants.baseFileLogDestinationIdentifier)
			
			let standardFileLogDestination: XCGFileLogDestination = XCGFileLogDestination(owner: hyberLog, writeToFile: true, identifier: XCGLogger.Constants.baseFileLogDestinationIdentifier)
			
			standardFileLogDestination.showLogIdentifier = false
			standardFileLogDestination.showFunctionName = true
			standardFileLogDestination.showThreadName = true
			standardFileLogDestination.showLogLevel = true
			standardFileLogDestination.showFileName = true
			standardFileLogDestination.showLineNumber = true
			standardFileLogDestination.showDate = true
			standardFileLogDestination.outputLogLevel = fileLogLevel
			
			hyberLog.addLogDestination(standardFileLogDestination)
			
		}
	}
	
	let consoleLogColors: [HyberXCGLoggerLogLevel: XCGLogger.XcodeColor] = [
		.Verbose: .lightGrey,
		.Debug: .darkGrey,
		.Info: .darkGreen,
		.Warning: XCGLogger.XcodeColor(fg: UIColor.orangeColor()),
		.Error: XCGLogger.XcodeColor(fg: UIColor.redColor()),
		.Severe: XCGLogger.XcodeColor(fg: UIColor.whiteColor(), bg: UIColor.redColor())
	]
	
}

/// Hyber did sign out notification name
internal let kHyberDidSignOut = "com.gms-worldwide.Hyber.DidSignOut"

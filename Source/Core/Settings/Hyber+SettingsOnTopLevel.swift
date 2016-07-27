//
//  Hyber+SettingsOnTopLevel.swift
//  Hyber
//
//  Created by Vitalii Budnik on 12/14/15.
//
//

import Foundation

private extension Hyber {
  
  /// A pointer to current settings `HyberSettings`
  private static let settings = helper.settings
  
}

internal extension Hyber {
  
	/// Current subscriber information
	static var registeredUser: HyberSubscriber? {
		set {
			hyberLog.verbose("New registered user: \(registeredUser)")
			settings.user = newValue
		}
		get {
			return settings.user
		}
	}

}

public extension Hyber {

  /// Subscriber's e-mail
  internal static var registeredUserEmail: String? {
    set {
      registeredUser?.email = newValue
    }
    get {
      return registeredUser?.email
    }
  }
  
  /// Subscriber's phone number
	public internal (set) static var registeredUserPhone: UInt64? {
    set {
      guard let newValue = newValue else { return }
      registeredUser?.phone = newValue
    }
    get {
      return registeredUser?.phone
    }
  }
	
  /// Firebase Messaging device token
	public internal (set) static var firebaseMessagingToken: String? {
		set {
			settings.firebaseMessagingToken = newValue
		}
		get {
			return settings.firebaseMessagingToken
		}
	}
	
  /// Global Message Services device token
	public internal (set) static var hyberDeviceId: UInt64 {
		set {
			settings.hyberDeviceId = newValue
		}
		get {
			return settings.hyberDeviceId
		}
	}
	
  /// Flag indicates if subscriber athorized or not
	public internal (set) static var authorized: Bool {
		set {
			settings.authorized = newValue
		}
		get {
			return settings.authorized
		}
	}
	
  /// Apple push-notification device token, represented as String
	public internal (set) static var apnsToken: String? {
		set {
			settings.apnsToken = newValue
		}
		get {
			return settings.apnsToken
		}
	}
	
  /**
   Sign outs current user and cleares all fetched data.
   - Returns: `true` if sign out successful, `false` otherwise
   */
	public static func signOut() -> Bool {
		
		hyberLog.info("Sign out")
		
    return settings.signOut()
		
	}
	
}

/// Log
extension Hyber {
	
	/**
	Console log level.
	Default: `.Verbose` with `DEBUG` mode on, '.Info' otherwise
	*/
	public static var consoleLogLevel: HyberXCGLoggerLogLevel {
		set {
			settings.consoleLogLevel = newValue
		}
		get {
			return settings.consoleLogLevel
		}
	}
	
	/**
	File log level
	Default: `.Verbose`
	*/
	public static var fileLogLevel: HyberXCGLoggerLogLevel {
		set {
			settings.fileLogLevel = newValue
		}
		get {
			return settings.fileLogLevel
		}
	}

	
}

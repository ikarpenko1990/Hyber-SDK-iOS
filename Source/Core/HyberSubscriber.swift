//
//  HyberSubscriber.swift
//  Hyber
//
//  Created by Vitalii Budnik on 12/10/15.
//  Copyright © 2015 Global Message Services Worldwide. All rights reserved.
//

import Foundation

/**
 Stores subscriber's e-mail & phone
 */
internal struct HyberSubscriber {
	
  /// Subscriber's e-mail
	var email: String?
  
  /// Subscriber's phone number
	var phone: UInt64
  
  /// Subscriber's registration date
  var registrationDate: NSDate?
	
  // swiftlint:disable valid_docs
  /**
   Initializes new subscriber with passed e-mail and phone
   - parameter email: `String` containig subscriber's e-mail
   - parameter phone: `Int64` containig subscriber's phone
   - returns: initialized instance
   */
  init(phone: UInt64, email: String?, registrationDate: NSDate? = .None) {
    // swiftlint:enable valid_docs
		self.email = email
		self.phone = phone
    self.registrationDate = registrationDate
	}
	
  // swiftlint:disable valid_docs
  /**
   Initializes new subscriber with passed dictionary
   - parameter dictionary: `[String: AnyObject]` containig subscriber's information 
   `["email": "SomeEmail", "phone": 380XXXXXXXXX]`. Can be `nil`
   - returns: initialized instance, or `nil`, if no dictionary passed
   */
	init?(withDictionary dictionary: [String: AnyObject]?) {
    
    guard let
      dictionary = dictionary,
      phoneNumber = dictionary["phone"] as? NSNumber
      where phoneNumber.unsignedLongLongValue > 1
      else { return nil }
    
    self.phone = phoneNumber.unsignedLongLongValue
    
    self.email = dictionary["email"] as? String
    
    if let registrationDate = dictionary["registrationDate"] as? NSNumber {
      self.registrationDate = NSDate(timeIntervalSinceReferenceDate: registrationDate.doubleValue)
//    } else if let registrationDate = dictionary["registrationDate"] as? Double {
//      self.registrationDate = NSDate(timeIntervalSinceReferenceDate: registrationDate)
    } else {
      self.registrationDate = .None
    }
    
  }
	
}

// MARK: DictionaryConvertible
internal extension HyberSubscriber {
	
  /**
   Converts current subscriber `struct` to dictionary `[String : AnyObject]` with subscribers e-mail and phone
   - returns: `[String : AnyObject]` dictionary with subscribers e-mail and phone
   */
	func asDictionary() -> [String : AnyObject] {
		var result = [String: AnyObject]()
		if let email = email {
			result["email"] = email
		}
//		if let phone = phone {
			result["phone"] = NSNumber(unsignedLongLong: phone)
//		}
    if let registrationDate = registrationDate {
      result["registrationDate"] = NSNumber(double: registrationDate.timeIntervalSinceReferenceDate)
    }
		return result
	}
	
}

// MARK: CutomStringConvertible
extension HyberSubscriber: Equatable {}

/**
 Compares two instances of `HyberSubscriber`
 - Parameter lhs: first `HyberSubscriber` instance to compare
 - Parameter rhs: second `HyberSubscriber` instance to compare
 - Returns: `true` if subscribers have equal phone numbers and e-mails, `false` otherwise
 */
internal func == (lhs: HyberSubscriber, rhs: HyberSubscriber) -> Bool {
	return lhs.email == rhs.email && lhs.phone == rhs.phone && lhs.registrationDate == rhs.registrationDate
}

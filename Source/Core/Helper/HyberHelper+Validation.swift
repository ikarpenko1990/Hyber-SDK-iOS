//
//  HyberHelper+Validation.swift
//  Hyber
//
//  Created by Vitalii Budnik on 3/28/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation

internal extension HyberHelper {

  /**
   Checks if there no mutually exclusive tasks
   
   - parameter checkHyberDeviceId: `Bool` indicates to check Global Message Services device token is set, or not
   - parameter completion: closure to execute, if checks not passed
   - returns: `true` if all checks passed, `false` otherwise
   */
  internal func canPreformAction<T>(
    checkHyberDeviceId: Bool,
    _ completion: ((HyberResult<T>) -> Void)? = .None)
    -> Bool // swiftlint:disable:this opening_brace
  {
    
    let errorCompletion: (HyberError.AnotherTaskInProgress) -> Void = { error in
      hyberLog.error(error.localizedDescription)
      completion?(.Failure(.AnotherTaskInProgressError(error)))
      return
    }
    
    if addSubscriberTask != nil {
      errorCompletion(.AddSubscriber)
      return false
    }
    
    if updateSubscriberInfoTask != nil {
      errorCompletion(.UpdateSubscriber)
      return false
    }
    
    if checkHyberDeviceId && Hyber.hyberDeviceId <= 0 {
      hyberLog.error(HyberError.HyberDeviceIdIsNotSet.localizedDescription)
      completion?(.Failure(.HyberDeviceIdIsNotSet))
      return false
    }
    
    return true
    
  }

  /**
   Validates email and phone number
   
   - parameter phone: `UInt64` containing subscriber's phone number. Can be `nil`
   - parameter email: `String` containing subscriber's e-mail address. Can be `nil`
   
   - returns: `true` if email or phone is setted and not empty, `false` otherwise.
   Executes `completionHandler` on `false`
   */
  func validatePhone(
    phone: UInt64?,
    email: String?)
    -> Bool // swiftlint:disable:this opening_brace
  {
    
    /// Email is empty
    let emailIsEmpty: Bool
    if let email = email {
      if email.isEmpty {
        emailIsEmpty = true
      } else {
        emailIsEmpty = false
      }
    } else {
      emailIsEmpty = true
    }
    
    // Phone is not valid
    let phoneNumberIsEmpty: Bool
    if let phone = phone {
      if phone < 1 {
        phoneNumberIsEmpty = true
      } else {
        phoneNumberIsEmpty = false
      }
    } else {
      phoneNumberIsEmpty = true
    }
    
    if emailIsEmpty && phoneNumberIsEmpty {
      return false
    }
    
    return true
  }
  
  /**
   Validates email and phone number
   
   - parameter phone: `UInt64` containing subscriber's phone number. Can be `nil`
   - parameter email: `String` containing subscriber's e-mail address. Can be `nil`
   - parameter completionHandler: The code to be executed when validation failed. (optional).
   This block takes no parameters. Returns `Result` `<T, HyberError>`
   
   - returns: `true` if email or phone is setted and not empty, `false` otherwise.
   Executes `completionHandler` on `false`
   */
  func validatePhone<T>(
    phone: UInt64?,
    email: String?,
    completionHandler completion: ((HyberResult<T>) -> Void)?)
    -> Bool // swiftlint:disable:this opening_brace
  {
    
    if !validatePhone(phone, email: email) {
      completion?(.Failure(.NoPhoneOrEmailPassed))
      return false
    }
    
    return true
  }
  
}

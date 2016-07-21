//
//  Hyber+Registration.swift
//  Hyber
//
//  Created by Vitalii Budnik on 12/14/15.
//
//

import Foundation
import UIKit

/** Makes pased clousure running in main thread
 - Parameter completion: async closure that must be runned in main thread later
 - Returns: Wrapped closure that will executed asynchronously in the main thread
 */
internal func completionHandlerInMainThread<T>(completion: (T -> Void)?) -> (T -> Void)? {
  if let completion = completion {
    return { result in
      if NSThread.isMainThread() {
        completion(result)
      } else {
        dispatch_async(dispatch_get_main_queue()) {
          completion(result)
        }
      }
    }
  } else {
    return .None
  }
}

/**
 Makes pased clousure running in main thread
 Returns Wrapped closure that will executed asynchronously in the main thread
 - Parameter completion: async closure that must be runned in main thread later
 - Returns: Wrapped closure that will executed asynchronously in the main thread
 */
internal func completionHandlerInMainThread<T>(completion: T -> Void) -> (T -> Void) {
  return { result in
    if NSThread.isMainThread() {
      completion(result)
    } else {
      dispatch_sync(dispatch_get_main_queue()) {
        completion(result)
      }
    }
  }
}

// MARK: - Subscriber Info
private extension HyberHelper {
  
  /**
   Updates subscriber's info on Global Message Services servers
   
   - parameter phone: `Int64` containing subscriber's phone number. Can't be `nil`
   - parameter email: `String` containing subscriber's e-mail address. Can be `nil`
   - parameter completionHandler: The code to be executed once the request has finished. (optional).
   This block takes no parameters. Returns `Result` `<Void, HyberError>`,
   where `result.error` contains `HyberError` if any error occurred
   */
  private func updateSubscriberInfo(
    phone phone: UInt64,
    email: String?,
    completionHandler completion: ((HyberResult<Void>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    if !canPreformAction(true, completion) {
      return
    }
    
    let email = email ?? ""
    
    if !validatePhone(phone, email: email, completionHandler: completion) {
      return
    }
    
    let requestParameters: [String: AnyObject] = [
      "uniqAppDeviceId": NSNumber(unsignedLongLong: Hyber.hyberDeviceId),
      "phone": NSNumber(unsignedLongLong: phone),
      "email": email.isEmpty ? NSNull() : email
    ]
    
    updateSubscriberInfoTask = HyberProvider.sharedInstance.POST(
      "lib_update_phone_email",
      parameters: requestParameters) { result in
        
        if Hyber.registeredUser?.phone != phone {
          HyberCoreDataHelper.managedObjectContext.deleteObjectctsOfAllEntities()
        }
        
        guard let _: [String: AnyObject] = result.value else {
          self.updateSubscriberInfoTask = .None
          completion?(.Failure(result.error ?? .UnknownError))
          return
        }
        
        Hyber.registeredUser = HyberSubscriber(phone: phone, email: email)
        
        self.updateSubscriberInfoTask = .None

        completion?(.Success())
        
    }
  }
  
  /**
   Adds a new subscriber on Global Message Services servers
   
   - parameter phone: `UInt64` containing subscriber's phone number. Can't be `nil`
   - parameter email: `String` containing subscriber's e-mail address. Can be `nil`
   - parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. Returns `Result` `<UInt64, HyberError>`, 
   where `result.value` contains `UInt64` Global Message Services device token if there no error occurred, 
   otherwise see `result.error`
   */
  private func addSubscriber(
    phone: UInt64,
    email: String?,
    completionHandler completion: ((HyberResult<UInt64>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    if !canPreformAction(completion) {
      return
    }
    
    let firebaseMessagingToken = Hyber.firebaseMessagingToken ?? ""
    
    let device = UIDevice.currentDevice()
        
    let email = email ?? ""
    
    if !validatePhone(phone, email: email, completionHandler: completion) {
      return
    }
    
    let requestParameters: [String: AnyObject] = [
      "uniqAppDeviceId": NSNull(),
      "phone": NSNumber(unsignedLongLong: phone),
      "email": email.isEmpty ? NSNull() : email,
      "gcmTokenId":  firebaseMessagingToken.isEmpty ? NSNull() : firebaseMessagingToken,
      "device_type": device.systemName,
      "device_version": device.systemVersion
    ]
    
    addSubscriberTask = HyberProvider.sharedInstance.POST(
      "lib_add_abonent",
      parameters: requestParameters) { result in
        
        guard let json: [String: AnyObject] = result.value else {
          self.addSubscriberTask = .None
          completion?(.Failure(result.error ?? .UnknownError))
          return
        }
        
        guard let uniqAppDeviceId = json["uniqAppDeviceId"] else {
          completion?(.Failure(.SubscriberError(.NoAppDeviceId)))
          return
        }
        
        guard let newHyberDeviceId = uniqAppDeviceId as? Double else {
          completion?(.Failure(.SubscriberError(.AppDeviceIdWrondType)))
          return
        }
        
        if newHyberDeviceId <= 0 {
          completion?(.Failure(.SubscriberError(.AppDeviceIdLessOrEqualZero)))
          return
        }
        
        Hyber.hyberDeviceId = UInt64(newHyberDeviceId)
        Hyber.registeredUser = HyberSubscriber(phone: phone, email: email)
        Hyber.authorized = true
        
        self.addSubscriberTask = .None
        
        self.getSubscribersProfile(completionHandler: completion)
        
    }
    
  }
  
  /**
   Gets subscriber's information from Global Message Services servers
   
   - parameter completionHandler: The code to be executed once the request has finished. (optional).
   This block takes no parameters. Returns `Result` `<UInt64, HyberError>`,
   where `result.value` contains `UInt64` Global Message Services device token if there no error occurred,
   otherwise see `result.error`
   */
  private func getSubscribersProfile(
    completionHandler completion: ((HyberResult<UInt64>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    if !canPreformAction(true, completion) {
      return
    }
    
    let hyberDeviceId = NSNumber(unsignedLongLong: Hyber.hyberDeviceId)
    
    HyberProvider.sharedInstance.POST(
      "get_profile",
      parameters: ["uniqAppDeviceId": hyberDeviceId]) { result in
        
        guard let json = result.value else {
          completion?(.Success(Hyber.hyberDeviceId))
          return
        }
        
        if let createdDate = json["created_date"] as? Double {
          var user = Hyber.registeredUser
          user?.registrationDate = NSDate(
            timeIntervalSince1970: createdDate / 1000.0)
          Hyber.registeredUser = user
          Hyber.helper.settings.save()
        }
        
        completion?(.Success(Hyber.hyberDeviceId))
    }
  }
  
}

internal extension HyberHelper {
  
  /**
   Checks if there no mutually exclusive tasks
   
   - parameter completion: closure to execute, if checks not passed
   - returns: `true` if all checks passed, `false` otherwise
   */
  private func canPreformAction<T>(
    completion: ((HyberResult<T>) -> Void)? = .None)
    -> Bool // swiftlint:disable:this opening_brace
  {
    return canPreformAction(false, completion)
  }
  	
}

// MARK: - Allow receive remote push-notifications
private extension HyberHelper {
  
  /**
   Updates subscriber's location on Global Message Services servers
   
   - parameter allowPush: `Bool`. `true` - allow recieve remote push notification, 
   `false` - deny recieve remote push notification
   - parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. Returns `Result` `<Void, HyberError>`,
   where `result.error` contains `HyberError` if any error occurred
   */
  private func allowRecievePush(
    allowPush: Bool,
    completionHandler completion: ((HyberResult<Void>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    if !canPreformAction(completion) {
      return
    }
    
    let errorCompletion: (HyberError) -> Void = { error in
      completion?(.Failure(error))
    }
    
    if Hyber.hyberDeviceId <= 0 {
      errorCompletion(.HyberDeviceIdIsNotSet)
      return
    }
    
    let requestParameters: [String: AnyObject] = [
      "uniqAppDeviceId": NSNumber(unsignedLongLong: Hyber.hyberDeviceId),
      "push_allowed": NSNumber(int: allowPush ? 1 : 0)
    ]
    
    let _ = HyberProvider.sharedInstance.POST(
      "lib_alow_recieve_push",
      parameters: requestParameters) { response in
        
        if response.isFailure(completion) {
          hyberLog.error((response.error ?? HyberError.UnknownError).localizedDescription)
          return
        }
        
        completion?(.Success())
    }
    
  }
  
}

// MARK: - Hyber Facade
public extension Hyber {
  
  /**
   Updates subscriber's location on Global Message Services servers
   
   - parameter allowPush: `Bool`. `true` - allow recieve remote push notification, 
   `false` - deny recieve remote push notification
   - parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. Returns `Result` `<Void, HyberError>`,
   where `result.error` contains `HyberError` if any error occurred
   */
  public static func allowRecievePush(
    allowPush: Bool,
    completionHandler completion: ((HyberResult<Void>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    helper.allowRecievePush(
      allowPush,
      completionHandler: completionHandlerInMainThread(completion))
    
  }
    
  /**
   Adds a new subscriber on Global Message Services servers
   
   - parameter phone: `Int64` containing subscriber's phone number. Can't be `nil`
   - parameter email: `String` containing subscriber's e-mail address. Can be `nil`
   - parameter completionHandler: The code to be executed once the request has finished. (optional).
   This block takes no parameters. Returns `Result` `<UInt64, HyberError>`, 
   where `result.value` contains `UInt64` Global Message Services device token if there no error occurred, 
   otherwise see `result.error`
   */
  public static func addSubscriber(
    phone: UInt64,
    email: String?,
    completionHandler completion: ((HyberResult<UInt64>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    helper.addSubscriber(
      phone,
      email: email,
      completionHandler: completionHandlerInMainThread(completion))
    
  }
  
  /**
   Updates subscriber's info on Global Message Services servers
   
   - parameter phone: `Int64` containing subscriber's phone number. Can't be `nil`
   - parameter email: `String` containing subscriber's e-mail address. Can be `nil`
   - parameter completionHandler: The code to be executed once the request has finished. (optional).
   This block takes no parameters. Returns `Result` `<Void, HyberError>`, 
   where `result.error` contains `HyberError` if any error occurred
   */
  public static func updateSubscriberInfo(
    phone phone: UInt64,
    email: String?,
    completionHandler completion: ((HyberResult<Void>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    helper.updateSubscriberInfo(
      phone: phone,
      email: email,
      completionHandler: completionHandlerInMainThread(completion))
    
  }
  
}

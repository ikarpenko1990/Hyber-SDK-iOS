//
//  HyberHelper+FirebaseMessagingToken.swift
//  Hyber
//
//  Created by Vitalii Budnik on 2/24/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation
import UIKit

// MARK: - GCM Token
private extension HyberHelper {
  
  /**
   Updates Firebase Messaging token on Global Message Services servers
   
   - parameter firebaseMessagingToken: `String?` containing Firebase Messaging token
   - parameter completionHandler: The code to be executed once the request has finished. (optional).
   This block takes no parameters. Returns `Result``<Void, HyberError>`,
   where `result.error` contains `HyberError` if any error occurred
   */
  private func updateFirebaseMessagingToken(
    firebaseMessagingToken: String?,
    completionHandler completion: ((HyberResult<Void>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
		Hyber.firebaseMessagingToken = firebaseMessagingToken
		
		if !canPreformAction(true, completion) {
      return
    }
		
    let errorCompletion: (HyberError) -> Void = { error in
      completion?(.Failure(error))
    }
    
    guard let firebaseMessagingToken = firebaseMessagingToken else {
      errorCompletion(.FirebaseMessagingTokenIsNotSet)
      return
    }
    
    let device = UIDevice.currentDevice()
    
    let requestParameters: [String: AnyObject] = [
      "uniqAppDeviceId": NSNumber(unsignedLongLong: Hyber.hyberDeviceId),
      "gcmTokenId"     : firebaseMessagingToken,
      "device_type"    : device.systemName,
      "device_version" : device.systemVersion
    ]
    
    HyberProvider.sharedInstance.POST("lib_update_token", parameters: requestParameters) { response in
      
      if response.isFailure(completion) {
        hyberLog.error((response.error ?? HyberError.UnknownError).localizedDescription)
        return
      }
      
      Hyber.allowRecievePush(self.settings.authorized) { response in
        completion?(response)
      }
      
    }
  }
  
}

public extension Hyber {
  
  /**
   Updates Firebase Messaging token on Global Message Services servers
   
   - parameter token: `String?` containing Firebase Messaging token
   - parameter completionHandler: The code to be executed once the request has finished. (optional).
   This block takes no parameters. Returns `Result``<Void, HyberError>`,
   where `result.error` contains `HyberError` if any error occurred
   */
  public static func updateFirebaseMessagingToken(
    firebaseMessagingToken: String?,
    completionHandler completion: ((HyberResult<Void>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    helper.updateFirebaseMessagingToken(
      firebaseMessagingToken,
      completionHandler: completionHandlerInMainThread(completion))
    
  }
  
}

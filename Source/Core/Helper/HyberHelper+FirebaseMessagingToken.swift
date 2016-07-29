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
		guard Hyber.firebaseMessagingToken != .None || firebaseMessagingToken != .None else {
			hyberLog.info("Saved firebase messaging token was nil, and a new one is nil too.")
			return
		}
		
		Hyber.firebaseMessagingToken = firebaseMessagingToken
		
		if !canPreformAction(true, completion) {
			hyberLog.error("Can't update firebase messaging token")
      return
    }
		
    let errorCompletion: (HyberError) -> Void = { error in
			hyberLog.error("updateFirebaseMessagingToken " + error.localizedDescription)
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
		
		hyberLog.verbose("Sending firebase token")
		
    HyberProvider.sharedInstance.POST("lib_update_token", parameters: requestParameters) { response in
      
      if response.isFailure(completion) {
				let error = response.error ?? .UnknownError
        hyberLog.error(error.localizedDescription)
				completion?(.Failure(error))
        return
      }
			
			hyberLog.debug("Firebase token sended")
			
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
		
    hyberLog.info("New firebase token came")
		
    helper.updateFirebaseMessagingToken(
      firebaseMessagingToken,
      completionHandler: completionHandlerInMainThread(completion))
    
  }
  
}

//
//  HyberHelper+GCMToken.swift
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
   Updates Google Cloud Messaging token on Global Message Services servers
   
   - parameter token: `String?` containing Google Cloud Messaging token
   - parameter completionHandler: The code to be executed once the request has finished. (optional).
   This block takes no parameters. Returns `Result``<Void, HyberError>`,
   where `result.error` contains `HyberError` if any error occurred
   */
  private func updateGCMToken(
    token: String?,
    completionHandler completion: ((HyberResult<Void>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    if !canPreformAction(true, completion) {
      return
    }
    
    Hyber.registeredGCMtoken = token
    
    let errorCompletion: (HyberError) -> Void = { error in
      //self.updateGCMTokenTask = .None
      completion?(.Failure(error))
    }
    
    guard let gcmToken = token else {
      errorCompletion(.GCMTokenIsNotSet)
      return
    }
    
    let device = UIDevice.currentDevice()
    
    let requestParameters: [String: AnyObject] = [
      "uniqAppDeviceId": NSNumber(unsignedLongLong: Hyber.registeredGMStoken),
      "gcmTokenId"     : gcmToken,
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
   Updates Google Cloud Messaging token on Global Message Services servers
   
   - parameter token: `String?` containing Google Cloud Messaging token
   - parameter completionHandler: The code to be executed once the request has finished. (optional).
   This block takes no parameters. Returns `Result``<Void, HyberError>`,
   where `result.error` contains `HyberError` if any error occurred
   */
  public static func updateGCMToken(
    token: String?,
    completionHandler completion: ((HyberResult<Void>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    helper.updateGCMToken(
      token,
      completionHandler: completionHandlerInMainThread(completion))
    
  }
  
}

//
//  HyberHelper+SubscribersLocation.swift
//  Hyber
//
//  Created by Vitalii Budnik on 2/24/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: - Location update
private extension HyberHelper {
  
  /// min location update `NSTimeInterval`
  private static let updateInterval: NSTimeInterval = 30 * 60 // 30 minutes
  
  /// `NSDate`, when last location successfully sended to Global Message Services server
  private static var lastUpdateLocation = NSDate(
    timeIntervalSinceNow: -(HyberHelper.updateInterval * 2))
  
  /**
   Updates subscriber's location on Global Message Services servers
   
   - parameter location: `CLLocation` containing subscriber's location. Can be `nil`
   - parameter completionHandler: The code to be executed once the request has finished. (optional).
   This block takes no parameters. Returns `Result` `<Void, HyberError>`,
   where `result.error` contains `HyberError` if any error occurred
   */
  private func updateSubscriberLocation(
    location: CLLocation?,
    completionHandler completion: ((HyberResult<Void>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    if !canPreformAction(true, completion) {
      return
    }
    
    let timestamp = location?.timestamp ?? NSDate()
    guard timestamp.timeIntervalSinceDate(HyberHelper.lastUpdateLocation)
      >= HyberHelper.updateInterval
      else { return }
    
    let requestParameters: [String: AnyObject] = [
      "uniqAppDeviceId": NSNumber(unsignedLongLong: Hyber.registeredGMStoken),
      "latitude": location?.coordinate.latitude ?? NSNull(),
      "longitude": location?.coordinate.longitude ?? NSNull(),
    ]
    
    HyberProvider.sharedInstance.POST("location", parameters: requestParameters) { response in
      
      guard !response.isFailure(completion) else {
        hyberLog.error((response.error ?? HyberError.UnknownError).localizedDescription)
        return
      }
      
      completion?(.Success())
      HyberHelper.lastUpdateLocation = timestamp
    }
    
  }
  
}

public extension Hyber {
  
  /**
   Updates subscriber's location on Global Message Services servers
   
   - parameter location: `CLLocation` containing subscriber's location. Can be `nil`
   - parameter completionHandler: The code to be executed once the request has finished. (optional).
   This block takes no parameters. Returns `Result` `<Void, HyberError>`,
   where `result.error` contains `HyberError` if any error occurred
   */
  public static func updateSubscriberLocation(
    location: CLLocation?,
    completionHandler completion: ((HyberResult<Void>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    helper.updateSubscriberLocation(
      location,
      completionHandler: completionHandlerInMainThread(completion))
    
  }

}

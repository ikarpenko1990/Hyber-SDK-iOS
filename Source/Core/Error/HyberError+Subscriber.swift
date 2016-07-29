//
//  HyberError+Subscriber.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/25/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation

// MARK: - HyberError.Subscriber
public extension HyberError {
  
  /**
   Enum represents response errors occured when adding new subscriber
   
   - NoAppDeviceId: There is no expexted `uniqAppDeviceId` field in response data
   - AppDeviceIdWrondType: Can't convert recieved `uniqAppDeviceId` to `UInt64`
   - AppDeviceIdLessOrEqualZero: Recieved `uniqAppDeviceId` is `0` or less
   */
  public enum Subscriber: ErrorType, CustomLocalizedDescriptionConvertible {
    
    /// here is no expexted `uniqAppDeviceId` field in response data
    case NoAppDeviceId
    
    /// Can't convert recieved `uniqAppDeviceId` to `UInt64`
    case AppDeviceIdWrondType
    
    /// Recieved `uniqAppDeviceId` is `0` or less
    case AppDeviceIdLessOrEqualZero
    
    /// A string containing the localized **template** of the object. (read-only)
    internal var localizedTemplate: String {
      let enumPresentation: String = "\(self)"
      return Hyber.bundle.localizedStringForKey(
        "Subscriber.\(enumPresentation)",
        value: .None,
        table: "HyberError")
    }
    
    /// A string containing the localized description of the object. (read-only)
    public var localizedDescription: String {
      let localizedString: String
      switch self {
      default:
        localizedString = localizedTemplate
        break
      }
      return localizedString
    }
    
  }
  
}

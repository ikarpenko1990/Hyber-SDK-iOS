//
//  HyberError+AnotherTaskInProgress.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/25/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation

// MARK: - HyberError.AnotherTaskInProgress
public extension HyberError {
  
  /**
   Enum represents errors occured when you trying launch
   
   - AddSubscriber: Adding new subscriber
   - UpdateSubscriber: Updating subscriber's info
   */
  public enum AnotherTaskInProgress: ErrorType, CustomLocalizedDescriptionConvertible {
    
    /// Adding new subscriber
    case AddSubscriber
    
    /// Updating subscriber's info
    case UpdateSubscriber
    
    /// A string containing the localized **template** of the object. (read-only)
    internal var localizedTemplate: String {
      let enumPresentation: String = "\(self)"
      return Hyber.bundle.localizedStringForKey(
        "AnotherTaskInProgress.\(enumPresentation)",
        value: .None,
        table: "HyberErrors")
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

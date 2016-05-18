//
//  HyberError+CoreData.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/25/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation

// MARK: - HyberError.CoreData
public extension HyberError {
  
  /**
   Enum represents errors occurred when saving data
   
   - `SaveError`(`NSError`): An error occurred while saving data.
   Contains a pointer to `NSError` object.
   - `FetchError`(NSError): An error occurred when fetching data.
   Contains a pointer to `NSError` object.
   */
  public enum CoreData: ErrorType, CustomLocalizedDescriptionConvertible {
    
    /// An error occurred when saving data. Contains a pointer to `NSError` object.
    case SaveError(NSError)
    
    /// An error occurred when fetching data. Contains a pointer to `NSError` object.
    case FetchError(NSError)
    
    /// A string containing the localized **template** of the object. (read-only)
    internal var localizedTemplate: String {
      let enumPresentation: String
      switch self {
      case SaveError(_):
        enumPresentation = "SaveError"
        break
      case FetchError(_):
        enumPresentation = "FetchError"
        break
      }
      return Hyber.bundle.localizedStringForKey(
        "CoreData.\(enumPresentation)",
        value: .None,
        table: "HyberErrors")
    }
    
    /// A string containing the localized description of the object. (read-only)
    public var localizedDescription: String {
      let localizedString: String
      switch self {
      case SaveError(let error):
        localizedString = String(format: localizedTemplate, error.localizedDescription)
        break
      case FetchError(let error):
        localizedString = String(format: localizedTemplate, error.localizedDescription)
        break
      }
      return localizedString
    }
  }
}

//
//  HyberError+MessageFetcher.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/25/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation

// MARK: - HyberError.MessageFetcher
public extension HyberError {
  
  /**
   Enum represents errors occurred when retrieving messages
   
   - NoPhone: Subscribers profile has no phone number
   - CoreDataSaveError(NSError): An error occurred while saving new messages.
   Contains a pointer to `NSError` object.
   */
  public enum MessageFetcher: ErrorType, CustomLocalizedDescriptionConvertible {
    
    /// Subscribers profile has no phone number
    case NoPhone
    
//    /// An error occurred while saving new messages. Contains a pointer to `NSError` object.
//    case CoreDataSaveError(NSError)
    
    /// A string containing the localized **template** of the object. (read-only)
    internal var localizedTemplate: String {
      let enumPresentation: String
      switch self {
//      case CoreDataSaveError:
//        enumPresentation = "CoreDataSaveError"
//        break
      default:
        enumPresentation = "\(self)"
        break
      }
      return Hyber.bundle.localizedStringForKey(
        "MessageFetcher.\(enumPresentation)",
        value: .None,
        table: "HyberError")
    }
    
    /// A string containing the localized description of the object. (read-only)
    public var localizedDescription: String {
      let localizedString: String
      switch self {
//      case CoreDataSaveError(let error):
//        localizedString = String(format: localizedTemplate, error.localizedDescription)
//        break
      default:
        localizedString = localizedTemplate
        break
      }
      return localizedString
    }
  }
  
}

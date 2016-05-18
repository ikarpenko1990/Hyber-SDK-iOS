//
//  HyberError+Request.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/25/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation

// MARK: - HyberError.Request
public extension HyberError {
  
  /**
   Enum represents request errors
   
   - Error: Request failed. Contains a pointer to `NSError` object.
   - ParametersSerializationError: Failed to serialize parameters, passed to request.
   Contains a pointer to `NSError` object.
   - UnknownError: Request failed but there is no any represenative error
   */
  public enum Request: ErrorType, CustomLocalizedDescriptionConvertible {
    
    /// Request failed. Contains a pointer to `NSError` object.
    case Error(NSError)
    
    /// Failed to serialize parameters, passed to request. Contains a pointer to `NSError` object.
    case ParametersSerializationError(NSError)
    
    /// Request failed but there is no any represenative error
    case UnknownError
    
    /// A string containing the localized **template** of the object. (read-only)
    internal var localizedTemplate: String {
      let enumPresentation: String
      switch self {
      case Error:
        enumPresentation = "Error"
        break
      case ParametersSerializationError:
        enumPresentation = "ParametersSerializationError"
        break
      default:
        enumPresentation = "\(self)"
        break
      }
      return Hyber.bundle.localizedStringForKey(
        "Request.\(enumPresentation)",
        value: .None,
        table: "HyberErrors")
    }
    
    /// A string containing the localized description of the object. (read-only)
    public var localizedDescription: String {
      let localizedString: String
      switch self {
      case Error(let error):
        localizedString = String(format: localizedTemplate, error.localizedDescription)
        break
      case ParametersSerializationError(let error):
        localizedString = String(format: localizedTemplate, error.localizedDescription)
        break
      default:
        localizedString = localizedTemplate
        break
      }
      return localizedString
    }
  }
  
}

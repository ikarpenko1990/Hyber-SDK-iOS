//
//  HyberError+ResultParsing.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/25/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation

// MARK: - HyberError.ResultParsing
public extension HyberError {
  
  /**
   Enum represents response parsing errors
   
   - CantRepresentResultAsDictionary: Request returned response `NSData`,
   that can't be represented as `[String: AnyObject]`
   - JSONSerializationError: Request returned response `NSData`, that can't be serialized to JSON.
   Contains `NSError?` - description of error, that occurred on serialization attempt
   - NoStatus: There is no expexted `status` flag in response data
   - StatusIsFalse: `status` flag in response data is `false`.
   Contains `String?` - description of error, that occurred on a remote server
   - UnknownError: Unknown error occurred when parsing response
   */
  public enum ResultParsing: ErrorType, CustomLocalizedDescriptionConvertible {
    
    /// Request returned response `NSData`, that can't be represented as `[String: AnyObject]`
    case CantRepresentResultAsDictionary
    
    /**
     Request returned response `NSData`, that can't be serialized to JSON.
     Contains `NSError?` - description of error, that occurred on serialization attempt
     */
    case JSONSerializationError(NSError)
    
    /// There is no expexted `status` flag in response data
    case NoStatus
    
    /**
     `status` flag in response data is `false`. Contains `String?` - description of error,
     that occurred on a remote server
     */
    case StatusIsFalse(String?)
    
    /// Unknown error occurred when parsing response
    case UnknownError
    
    /// A string containing the localized **template** of the object. (read-only)
    internal var localizedTemplate: String {
      let enumPresentation: String
      switch self {
      case StatusIsFalse:
        enumPresentation = "StatusIsFalse"
        break
      default:
        enumPresentation = "\(self)"
        break
      }
      return Hyber.bundle.localizedStringForKey(
        "ResultParsing.\(enumPresentation)",
        value: .None,
        table: "HyberErrors")
    }
    
    /// A string containing the localized description of the object. (read-only)
    public var localizedDescription: String {
      let localizedString: String
      switch self {
      case StatusIsFalse(let errorString):
        localizedString = String(format: localizedTemplate, errorString ?? "")
        break
      default:
        localizedString = localizedTemplate
        break
      }
      return localizedString
    }
  }
  
}

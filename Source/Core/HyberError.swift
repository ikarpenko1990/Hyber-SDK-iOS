//
//  HyberErrors.swift
//  Hyber
//
//  Created by Vitalii Budnik on 12/10/15.
//  Copyright © 2015 Global Messages Services Worldwide. All rights reserved.
//

import Foundation

/// Object containing the localized description of `self`
public protocol CustomLocalizedDescriptionConvertible {
  /// A string containing the localized description of the object. (read-only)
  var localizedDescription: String { get }
}

// MARK: - HyberError
/**
 Enum represents Hyber framework errors
 
 - RequestError: A HTTP request error. Contains `HyberError.Request`
 - ResultParsingError: An error occured when parsing result. Contains 
`HyberError.ResultParsing`
 - SubscriberError: An error occured when adding new subscriber. 
Contains `HyberError.Subscriber`
 - AnotherTaskInProgressError: Another task in progress error. 
Contains `HyberError.AnotherTaskInProgress`
 - MessageFetcherError: Error occurred when retrieving messages. Contains 
`HyberError.MessageFetcher`
 - CoreDataError: Error occurred when saving data. Contains
 `HyberError.CoreData`
 - GMSTokenIsNotSet: Global Message Service token is not set
 - GCMTokenIsNotSet: Google Cloud Messaging token is not set
 - NoPhoneOrEmailPassed: No phone or e-mail is passed
 - UnknownError: An unknown error occurred
 */
public enum HyberError: ErrorType {
  
  /// A HTTP request error. Contains `HyberError.Request`
  case RequestError(Request)
  
  /// An error occured when parsing result. Contains `HyberError.ResultParsing`
  case ResultParsingError(ResultParsing)
  
  /// An error occured when adding new subscriber. Contains `HyberError.Subscriber`
  case SubscriberError(Subscriber)
  
  /// Another task in progress error. Contains `HyberError.AnotherTaskInProgress`
  case AnotherTaskInProgressError(AnotherTaskInProgress)
  
  /// Error occurred when retrieving messages. Contains `HyberError.MessageFetcher`
  case MessageFetcherError(MessageFetcher)
  
  /// Error occurred when saving data. Contains `HyberError.CoreData`
  case CoreDataError(CoreData)
  
  /// Global Message Service token is not set
  case GMSTokenIsNotSet
  
  /// Google Cloud Messaging token is not set
  case GCMTokenIsNotSet
  
  /// An unknown error occurred
  case NotAuthorized
  
  /// No phone or e-mail is passed
  case NoPhoneOrEmailPassed
  
  /// An unknown error occurred
  case UnknownError
  
  /// A string containing the localized **template** of the object. (read-only)
  private var localizedTemplate: String {
    let enumPresentation: String
    switch self {
    case RequestError(let error):
      enumPresentation = error.localizedTemplate
      break
    case ResultParsingError(let error):
      enumPresentation = error.localizedTemplate
      break
    case SubscriberError(let error):
      enumPresentation = error.localizedTemplate
      break
    case AnotherTaskInProgressError(let error):
      enumPresentation = error.localizedTemplate
      break
    case MessageFetcherError(let error):
      enumPresentation = error.localizedTemplate
      break
    case CoreDataError(let error):
      enumPresentation = error.localizedTemplate
      break
    default:
      enumPresentation = "\(self)"
      break
    }
    return Hyber.bundle.localizedStringForKey(
      "HyberError.\(enumPresentation)",
      value: .None,
      table: "HyberErrors")
  }
  
  /// A string containing the localized description of the object. (read-only)
  public var localizedDescription: String {
    let localizedString: String
    switch self {
    case RequestError(let error):
      localizedString = error.localizedDescription
      break
    case ResultParsingError(let error):
      localizedString = error.localizedDescription
      break
    case SubscriberError(let error):
      localizedString = error.localizedDescription
      break
    case AnotherTaskInProgressError(let error):
      localizedString = error.localizedDescription
      break
    case MessageFetcherError(let error):
      localizedString = error.localizedDescription
      break
    case CoreDataError(let error):
      localizedString = error.localizedDescription
      break
    default:
      localizedString = localizedTemplate
      break
    }
    return localizedString
  }
  
}

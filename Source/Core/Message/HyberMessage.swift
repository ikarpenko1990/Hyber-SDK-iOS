//
//  HyberMessage.swift
//  Hyber
//
//  Created by Vitalii Budnik on 1/25/16.
//
//

import Foundation

/**
 `Struct` representing delivered message to subscriber
 */
public struct HyberMessage: Hashable, HyberMessageData {
  
  /**
   `String` representing sender. Can't be `nil`
   */
  public let sender: String
  
  /**
   `String` representing message body. Can't be `nil`
   */
  public let messageBody: String
  
  /**
   Message delivered `NSDate`
   */
  public let deliveredDate: NSDate
  
  /**
   Message type
   - SeeAlso: `HyberMessageType` for details
   */
  public let type: HyberMessageType
  
  /**
   `UInt64` Global Message Services message id
   */
  public let id: UInt64 // swiftlint:disable:this variable_name
  
  // swiftlint:disable valid_docs
  /**
   Initializes a new instance of `HyberMessageData` from `HyberDataInboxMessage`
   - Parameter message: `HyberDataInboxMessage` object
   - Returns: Converted object from `HyberDataInboxMessage` if successfully converted, `nil` otherwise
   */
  internal init?(message: HyberDataInboxMessage) {
    // swiftlint:enable valid_docs
    guard let
      type = HyberMessageType(rawValue: message.type),
      fetchedDate = message.fetchedDate
      else {
      return nil
    }
    
    if fetchedDate.to != Int64(Hyber.registeredUserPhone ?? 0) {
      return nil
    }
    
    self.sender        = message.getSenderNameString()
    self.messageBody   = message.message ?? ""
    self.id            = message.messageID?.unsignedLongLongValue ?? 0
    
    self.deliveredDate = NSDate(timeIntervalSinceReferenceDate: message.deliveredDate)
    
    self.type          = type
    
  }
  
  // swiftlint:disable valid_docs
  /**
   Initializes a new instance of `HyberMessageData` from `HyberPushNotification`
   - Parameter pushNotification: `HyberPushNotification` object
   - Returns: Converted object from `HyberPushNotification` if successfully converted, 
   `nil` otherwise
  */
  public init(pushNotification: HyberPushNotification) {
    // swiftlint:enable valid_docs
    self.sender        = pushNotification.sender
    self.messageBody   = pushNotification.body ?? ""
    self.id            = pushNotification.hyberMessageID
    
    self.deliveredDate = pushNotification.deliveredDate
    
    self.type          = .PushNotification
  }
  
  // swiftlint:disable valid_docs
  /**
   Initializes a new instance of `HyberMessageData` from `[String: AnyObject]`
   - Parameter dictionary: Dictionary<String, AnyObject> describing message
   - Returns: Converted object from ` Dictionary<String, AnyObject>` if successfully converted, 
   `nil` otherwise
   */
  internal init?(
    // swiftlint:enable valid_docs

    dictionary: Dictionary<String, AnyObject>,
    andType type: HyberMessageType) // swiftlint:disable:this opening_brace
  {
    
    guard let
      from = dictionary["from"] as? String,
      to = dictionary["to"] as? Double,
      message = dictionary["message"] as? String,
      id = dictionary["msg_uniq_id"] as? Double,
      deliveredTimeStamp = dictionary["deliveredDate"] as? Double
      else  // swiftlint:disable:this opening_brace
    {
      return nil
    }
    
    if UInt64(to) != Hyber.registeredUserPhone {
      return nil
    }
    
    self.sender        = from
    //self.to            = UInt64(to)
    self.messageBody   = message
    self.id            = UInt64(id)
    
    self.deliveredDate = NSDate(timeIntervalSince1970: deliveredTimeStamp / 1000.0)
    
    self.type          = type
    
  }
    
  /**
   Delete message (CoreData)
   
   - returns: `true` if successfully deleted, `nil` otherwise
   */
  public func delete() -> Bool {
    let predicate = searchPredicate()//,
      //NSNumber(short: ))
    let moc = HyberCoreDataHelper.newManagedObjectContext()
    if let gmsHyberDataInboxMessage = HyberDataInboxMessage.findObject(
      withPredicate: predicate,
      inManagedObjectContext: moc,
      createNewIfNotFound: false) as? HyberDataInboxMessage //swiftlint:disable:this opening_brace
    {
      gmsHyberDataInboxMessage.deletionMark = true
      
      let result = moc.saveSafeRecursively()
      switch result {
      case .Failure(_):
        return false
      default:
        return true
      }
    }
    return false
  }
  
}

/**
 Compares two `HyberMessage`s
 - Parameter lhs: frirst `HyberMessage`
 - Parameter rhs: second `HyberMessage`
 - Returns: `true` if both messages are equal, otherwise returns `false`
 */
@warn_unused_result public func == (
  lhs: HyberMessage,
  rhs: HyberMessage)
  -> Bool //swiftlint:disable:this opening_brace
{
  return lhs.sender == rhs.sender
    && lhs.type == rhs.type
    && lhs.id == rhs.id
    && lhs.deliveredDate.timeIntervalSinceReferenceDate == rhs.deliveredDate.timeIntervalSinceReferenceDate
}

/**
 Compares two `HyberMessage`s
 - Parameter lhs: frirst `HyberMessage`
 - Parameter rhs: second `HyberMessage`
 - Returns: `true` if both messages are equal, otherwise returns `false`
 */
@warn_unused_result public func == (
  lhs: HyberMessage?,
  rhs: HyberMessage?)
  -> Bool //swiftlint:disable:this opening_brace
{
  if let lhs = lhs {
    if let rhs = rhs {
      return lhs.sender == rhs.sender
        && lhs.type == rhs.type
        && lhs.id == rhs.id
        && lhs.deliveredDate.timeIntervalSinceReferenceDate
          == rhs.deliveredDate.timeIntervalSinceReferenceDate
    } else {
      return false
    }
  } else {
    if let _ = rhs {
      return false
    } else {
      return true
    }
  }
  
}

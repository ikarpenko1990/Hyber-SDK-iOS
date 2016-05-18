//
//  HyberMessageData.swift
//  Hyber
//
//  Created by Vitalii Budnik on 5/18/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation

/// Hyber Message Data
public protocol HyberMessageData {
  
  /**
   `String` representing message body. Can't be `nil`
   */
  var messageBody: String { get }
  
  /**
   Message delivered `NSDate`
   */
  var deliveredDate: NSDate { get }
  
  /**
   `String` representing sender. Can't be `nil`
   */
  var sender: String { get }
  
  /**
   `UInt64` Global Message Services message id
   */
  var id: UInt64 { get } //swiftlint:disable:this variable_name
  
  /**
   Message type
   - SeeAlso: `HyberMessageType` for details
   */
  var type: HyberMessageType { get }
  
  /**
   The hash value.
   
   **Axiom:** `x == y` implies `x.hashValue == y.hashValue`.
   
   - Note: The hash value is not guaranteed to be stable across
   different invocations of the same program.  Do not persist the
   hash value across program runs.
   
   */
  var hashValue: Int { get }
  
  /**
   Delete message (CoreData)
   
   - returns: `true` if successfully deleted, `nil` otherwise
   */
  func delete() -> Bool
}

extension HyberMessageData {
  
  /**
   The hash value.
   
   **Axiom:** `x == y` implies `x.hashValue == y.hashValue`.
   
   - Note: The hash value is not guaranteed to be stable across
   different invocations of the same program.  Do not persist the
   hash value across program runs.
   
   */
  public var hashValue: Int {
    return "\(sender)\(deliveredDate.timeIntervalSinceReferenceDate)\(id)\(type.rawValue)".hash
  }
  
  /**
   Returns `NSPredicate` to identify message
   
   - returns: `NSPredicate` to identify message
   */
  internal func searchPredicate() -> NSPredicate {
    return NSPredicate(
      format: "messageID == %@ && deliveredDate == %@ && type == \(type.rawValue)",
      NSDecimalNumber(unsignedLongLong: id),
      deliveredDate)
  }
  
}

/**
 Compares two `HyberMessage`s
 - Parameter lhs: frirst `HyberMessage`
 - Parameter rhs: second `HyberMessage`
 - Returns: `true` if both messages are equal, otherwise returns `false`
 */
@warn_unused_result public func == (
  lhs: HyberMessageData?,
  rhs: HyberMessageData?)
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
  }
  
  return rhs == nil
  
}

/**
 Compares two `HyberMessageData`s
 - Parameter lhs: frirst `HyberMessageData`
 - Parameter rhs: second `HyberMessageData`
 - Returns: `true` if both messages are equal, otherwise returns `false`
 */
@warn_unused_result
public func == (
  lhs: HyberMessageData,
  rhs: HyberMessageData)
  -> Bool //swiftlint:disable:this opening_brace
{
  return lhs.sender == rhs.sender
    && lhs.type == rhs.type
    && lhs.id == rhs.id
    && lhs.deliveredDate.timeIntervalSinceReferenceDate == rhs.deliveredDate.timeIntervalSinceReferenceDate
}

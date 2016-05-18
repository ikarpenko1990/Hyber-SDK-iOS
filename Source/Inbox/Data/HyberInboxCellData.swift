//
//  HyberInboxCellData.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/22/16.
//
//

import Foundation

/**
 Hyber Inbox Cell Data
 */
public struct HyberInboxCellData: Hashable {
  let type: HyberInboxCellType
  let message: HyberMessageData?
  let showMessageType: Bool
  let showTime: Bool
  let showSenderTitle: Bool
  let indentAvatar: Bool
  let showAvatar: Bool
  
  init() {
    
    self.type = .Refresh
    self.message = .None
    
    self.showMessageType = false
    self.showTime = false
    self.showSenderTitle = false
    
    self.indentAvatar = false
    
    self.showAvatar = false
    
  }
  
  init(
    message: HyberMessageData,
    showMessageType: Bool,
    showTime: Bool,
    showSenderTitle: Bool,
    indentAvatar: Bool) //swiftlint:disable:this opening_brace
  {
    self.type = .Header
    self.message = message
    
    self.showMessageType = showMessageType
    self.showTime = showTime
    self.showSenderTitle = showSenderTitle
    
    self.indentAvatar = indentAvatar
    
    self.showAvatar = false
    
  }
  
  init(
    message: HyberMessageData,
    indentAvatar: Bool,
    showAvatar: Bool) //swiftlint:disable:this opening_brace
  {
    self.type = .Message
    self.message = message
    
    self.showMessageType = false
    self.showTime = false
    self.showSenderTitle = false
    
    self.indentAvatar = indentAvatar
    
    self.showAvatar = showAvatar
    
  }
}

public extension HyberInboxCellData {
  
    /// `true` if this is message, `false` otherwise
  var isMessage: Bool {
    return type.isMessage
  }
  
  /// `true` if this is header, `false` otherwise
  var isHeader: Bool {
    return type.isHeader
  }
  
  /// `true` if this is refresh cell, `false` otherwise
  var isRefresh: Bool {
    return type.isRefresh
  }
  
  /** The hash value.
   
   **Axiom:** `x == y` implies `x.hashValue == y.hashValue`.
   
   - Note: The hash value is not guaranteed to be stable across
   different invocations of the same program.  Do not persist the
   hash value across program runs.
   */
  var hashValue: Int {
    
    return String(format: "type=%i message=%i showMessageType=%i "
      + "showTime=%i showSenderTitle=%i indentAvatar=%i showAvatar=%i",
                  type.hashValue,
                  message?.hashValue ?? 0,
                  showMessageType,
                  showTime,
                  showSenderTitle,
                  indentAvatar,
                  showAvatar).hashValue
    
  }
  
}

/**
 Compares two `HyberInboxCellData`s
 - Parameter lhs: frirst `HyberInboxCellData`
 - Parameter rhs: second `HyberInboxCellData`
 - Returns: `true` if cells are equal, otherwise returns `false`
 */
@warn_unused_result public func == (lhs: HyberInboxCellData, rhs: HyberInboxCellData) -> Bool {
  return lhs.type == rhs.type
    && lhs.message == rhs.message
    && lhs.showMessageType == rhs.showMessageType
    && lhs.showTime == rhs.showTime
    && lhs.showSenderTitle == rhs.showSenderTitle
    && lhs.indentAvatar == rhs.indentAvatar
    && lhs.showAvatar == rhs.showAvatar
}

/**
 Almost equal
 */
infix operator ~= { associativity left precedence 160 }


/**
 Compares two `HyberInboxCellData`s
 - Parameter lhs: frirst `HyberInboxCellData`
 - Parameter rhs: second `HyberInboxCellData`
 - Returns: `true` if cells has same type and message, otherwise returns `false`.
 - Warning: Not exactly equal
 */
func ~= (lhs: HyberInboxCellData, rhs: HyberInboxCellData) -> Bool {
  
  return lhs.type == rhs.type
    && lhs.message == rhs.message
  
}

//
//  HyberInboxCellType.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/22/16.
//
//

import Foundation

/// Hyber Inbox Cell Type
public enum HyberInboxCellType: Int, Hashable {
  case Header = 0
  case Message
  case Refresh
  
  /** The hash value.
  
   **Axiom:** `x == y` implies `x.hashValue == y.hashValue`.
  
   - Note: The hash value is not guaranteed to be stable across
     different invocations of the same program.  Do not persist the
     hash value across program runs.
   */
  public var hashValue: Int {
    return self.rawValue
  }
  
  /// Cell type is message
  var isMessage: Bool {
    switch self {
    case .Message:
      return true
    default:
      return false
    }
  }
  
  /// Cell type is refresh
  var isRefresh: Bool {
    switch self {
    case .Refresh:
      return true
    default:
      return false
    }
  }

  /// Cell type is header
  var isHeader: Bool {
    switch self {
    case .Header:
      return true
    default:
      return false
    }
  }
}

/**
 Compares two `HyberInboxCellType`s
 - Parameter lhs: frirst `HyberInboxCellType`
 - Parameter rhs: second `HyberInboxCellType`
 - Returns: `true` if cell types are equal, otherwise returns `false`
 */
@warn_unused_result public func == (lhs: HyberInboxCellType, rhs: HyberInboxCellType) -> Bool {
  return lhs.rawValue == rhs.rawValue
}

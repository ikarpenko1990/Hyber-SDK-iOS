//
//  HyberMessageType.swift
//  Hyber
//
//  Created by Vitalii Budnik on 3/2/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation

/**
 Delivered messages types
 - PushNotification: Push-notification
 - SMS: SMS
 - Viber: Viber
 */
public enum HyberMessageType: Int16, Hashable, CustomStringConvertible {
  
  /// Push-notification
  case PushNotification = 1
  
  /// SMS
  case SMS = 2
  
  /// Viber
  case Viber = 3
  
  /// A textual representation of self.
  public var description: String {
    let descriptionString: String
    switch self {
    case .PushNotification:
      descriptionString = "PUSH"
    case .SMS:
      descriptionString = "SMS"
    case .Viber:
      descriptionString = "VIBER"
    }
    return Hyber.bundle.localizedStringForKey(
      descriptionString,
      value: .None,
      table: "HyberMessageTypes")
  }
  
  /// Array of all available `HyberMessageType`s
  public static let allItems: [HyberMessageType] = {
    return [.PushNotification, .SMS, .Viber]
  }()
  
  /**
   REST API fetch delivered messages suffix
   - Returns: `String` with REST API fetch delivered messages suffix
   */
  internal func requestSuffix() -> String {
    switch self {
    case .PushNotification:
      return "push"
    case .SMS:
      return "sms"
    case .Viber:
      return "viber"
    }
  }
  
}

//
//  HyberLabelsStyles.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/22/16.
//
//

import Foundation

/**
 Labels styles
 */
public protocol HyberLabelsStyles {
  
  /// Message label style
  var messageLabelStyle: HyberTextLabelStyle { get }
  
  /// Time label style
  var timeLabelStyle: HyberTimeLabelStyle { get }
  
  /// Date/time label style
  var dateLabelStyle: HyberDateTimeLabelStyle { get }
  
  /// Message type label style
  var messageTypeLabelStyle: HyberTextLabelStyle { get }
  
  /// Sender label style
  var senderLabelStyle: HyberTextLabelStyle { get }
  
  
  /**
   Returns initialized labels styles
   
   - returns: Initialized labels styles
   */
  static func initLabelStyles()
    -> (
    messageLabelStyle: HyberTextLabelStyle,
    timeLabelStyle: HyberTimeLabelStyle,
    dateLabelStyle: HyberDateTimeLabelStyle,
    messageTypeLabelStyle: HyberTextLabelStyle,
    senderLabelStyle: HyberTextLabelStyle)
  
  /**
   Sets locale identifier
   
   - parameter locale: new locale identifier
   */
  func setLocale(locale: NSLocale)
  
}

public extension HyberLabelsStyles {
  
  /**
   Sets locale identifier
   
   - parameter locale: new locale identifier
   */
  public func setLocale(locale: NSLocale) {
    dateLabelStyle.setLocale(locale)
    timeLabelStyle.setLocale(locale)
  }
  
}

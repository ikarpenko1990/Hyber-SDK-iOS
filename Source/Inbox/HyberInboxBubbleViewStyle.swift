//
//  HyberInboxBubbleViewStyle.swift
//  Hyber
//
//  Created by Vitalii Budnik on 5/18/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation
import UIKit

/**
 Hyber Inbox Bubble View Style
 */
public struct HyberInboxBubbleViewStyle: HyberBubbleViewStyle {
  
  /**
   Returns bubble styles for all known `HyberMessageType`s
   
   - returns: `[HyberMessageType: HyberBubbleViewStyle]` - bubble styles for all known `HyberMessageType`s
   */
  public static func allBubbleStyles() -> [HyberMessageType: HyberBubbleViewStyle] {
    return [
      .SMS: HyberInboxBubbleViewStyle.sms(),
      .Viber: HyberInboxBubbleViewStyle.viber(),
      .PushNotification: HyberInboxBubbleViewStyle.push()
    ]
  }
  
  /**
   Returns default bubble view style
   
   - returns: Default bubble view style
   */
  public static func defaultStyle() -> HyberBubbleViewStyle {
    return push()
  }
  
  /// Bubble color
  public let bubbleColor: UIColor
  /// Text color
  public let textColor: UIColor
  
  /**
   Creates new new `HyberInboxBubbleViewStyle`
   
   - parameter bubbleColor: Bubble color
   - parameter textColor: Text color. Default: `.whiteColor()`
   
   */
  public init(bubbleColor: UIColor,
              textColor: UIColor = .whiteColor()) // swiftlint:disable:this opening_brace
  {
    
    self.bubbleColor = bubbleColor
    self.textColor = textColor
    
  }
  
  /**
   Returns `HyberBubbleViewStyle` for SMS
   
   - returns: `HyberBubbleViewStyle` for SMS
   */
  private static func sms() -> HyberBubbleViewStyle {
    return self.init(
      bubbleColor: UIColor(
        red: 0.0/255.0,
        green: 195.0/255.0,
        blue: 82.0/255.0,
        alpha: 1.0))
  }
  
  /**
   Returns `HyberBubbleViewStyle` for Viber
   
   - returns: `HyberBubbleViewStyle` for Viber
   */
  private static func viber() -> HyberBubbleViewStyle {
    return self.init(
      bubbleColor: UIColor(
        red: 124.0 / 255.0,
        green: 83.0 / 255.0,
        blue: 156.0 / 255.0,
        alpha: 1.0))
  }
  
  /**
   Returns `HyberBubbleViewStyle` for Push-notification
   
   - returns: `HyberBubbleViewStyle` for Push-notification
   */
  private static func push() -> HyberBubbleViewStyle {
    return self.init(
      bubbleColor: UIColor(
        red: 229.0 / 255.0,
        green: 229.0 / 255.0,
        blue: 234.0 / 255.0,
        alpha: 1.0),
      textColor: UIColor.blackColor())
  }
  
}

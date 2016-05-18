//
//  HyberBubbleViewStyle.swift
//  Hyber
//
//  Created by Vitalii Budnik on 5/18/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation
import UIKit

/// Bubble view style
public protocol HyberBubbleViewStyle {
  
  /// Bubble color
  var bubbleColor: UIColor { get }
  
  /// Text color
  var textColor: UIColor { get }
  
  /**
   Creates new new `HyberBubbleViewStyle`
   
   - parameter bubbleColor: Bubble color
   - parameter textColor: Text color
   
   - returns: New `HyberBubbleViewStyle`
   */
  init(bubbleColor: UIColor, textColor: UIColor)
  
  /**
   Returns bubble styles for all known `HyberMessageType`s
   
   - returns: `[HyberMessageType: HyberBubbleViewStyle]` - bubble styles for all known `HyberMessageType`s
   */
  static func allBubbleStyles() -> [HyberMessageType: HyberBubbleViewStyle]
  
  /**
   Returns default bubble view style
   
   - returns: Default bubble view style
   */
  static func defaultStyle() -> HyberBubbleViewStyle
  
}

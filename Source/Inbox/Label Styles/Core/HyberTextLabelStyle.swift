//
//  HyberTextLabelStyle.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/22/16.
//
//

import Foundation
import UIKit

/**
 Hyber Text Label Style
 */
public protocol HyberTextLabelStyle {
  
  /// Label font
  var font: UIFont { get }
  
  /// Label color
  var color: UIColor { get }
  
  /// Text attributes for `NSAttributedString`
  var attributes: [String: AnyObject] { get }
  
  /**
   Returns attributed string
   
   - parameter string: `String` to make attributed
   
   - returns: Attributed string
   */
  func attributedString(string: String) -> NSAttributedString
}

public extension HyberTextLabelStyle {
  
    /// Text attributes for `NSAttributedString`
  public var attributes: [String: AnyObject] {
    return [
      NSFontAttributeName : font,
      NSForegroundColorAttributeName: color]
  }
  
  /**
   Returns attributed string
   
   - parameter string: `String` to make attributed
   
   - returns: Attributed string
   */
  public func attributedString(string: String) -> NSAttributedString {
    return string.attributedString(attributes)
  }
  
}

//
//  HyberTimeLabelStyle.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/22/16.
//
//

import Foundation
import UIKit

/**
 Hyber Time Label Style
 */
public protocol HyberTimeLabelStyle: HyberTextLabelStyle {
  
  /// Time formatter
  var timeFormatter: NSDateFormatter { get }
  
  /**
   Returns max width for label
   
   - returns: max width for label
   */
  func maxTimeWidth() -> CGFloat
  
  /**
   Sets new locale
   
   - parameter locale: new locale identifier
   */
  func setLocale(locale: NSLocale)
  
  func attributedString(date: NSDate) -> NSAttributedString
  
}

public extension HyberTimeLabelStyle {
  
  /**
   Sets new locale
   
   - parameter locale: new locale identifier
   */
  public func setLocale(locale: NSLocale) {
    timeFormatter.locale = locale
  }
  
  /**
   Returns max width for label
   
   - returns: max width for label
   */
  public func maxTimeWidth() -> CGFloat {
    let label = UILabel()
    label.font = font
    label.text = timeFormatter.locale.is24HoursFormat() ? "03:44" : "10:44 AM"
    let enWidth = label.sizeThatFits(CGSize.max).width
    
    return fmax(ceil(enWidth), 0.0)
  }
  
  /**
   Converts passed `date` to `NSAttributedString`
   
   - parameter date: `NSDate`
   
   - returns: Attributed string from passed date
   */
  func attributedString(date: NSDate) -> NSAttributedString {
    
    return attributedString(timeFormatter.stringFromDate(date))
    
  }
  
}

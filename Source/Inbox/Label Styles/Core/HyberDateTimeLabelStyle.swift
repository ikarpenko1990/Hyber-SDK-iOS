//
//  HyberDateTimeLabelStyle.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/22/16.
//
//

import Foundation
import UIKit

/**
 Hyber Date Time Label Style
 */
public protocol HyberDateTimeLabelStyle: HyberTimeLabelStyle {
  /// Date `NSDateFormatter`
  var dateFormatter: NSDateFormatter { get }
  
  /// Time part style
  var timeLabelStyle: HyberTimeLabelStyle? { get }
}

public extension HyberDateTimeLabelStyle {
  
  /**
   Sets new locale
   
   - parameter locale: new locale identifier
   */
  public func setLocale(locale: NSLocale) {
    dateFormatter.locale = locale
    timeFormatter.locale = locale
  }
  
  /**
   Converts passed `date` to `NSAttributedString`
   
   - parameter date: `NSDate` to make attributed
   
   - returns: Attributed string
   */
  public func attributedString(date: NSDate) -> NSAttributedString {
    
    let dateString = dateFormatter.stringFromDate(date)
    let dateAttributedString = attributedString(dateString)
    
    let timeString = " " + timeFormatter.stringFromDate(date)
    let timeAttributedString = timeLabelStyle?.attributedString(timeString) ?? attributedString(timeString)
    
    let timeLabelString = NSMutableAttributedString(attributedString: dateAttributedString)
    timeLabelString.appendAttributedString(timeAttributedString)
    
    return timeLabelString
    
  }
  
}

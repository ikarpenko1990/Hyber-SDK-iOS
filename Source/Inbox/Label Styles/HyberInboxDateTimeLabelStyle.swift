//
//  HyberInboxDateTimeLabelStyle.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/22/16.
//
//

import Foundation
import UIKit

/**
 Hyber Inbox Date Time Label Style
 */
public struct HyberInboxDateTimeLabelStyle: HyberDateTimeLabelStyle {
  
  /// Label font
  public let font: UIFont
  /// Label color
  public let color: UIColor
  
  public let timeLabelStyle: HyberTimeLabelStyle?
  
  /// Time `NSDateFormatter`
  public let timeFormatter: NSDateFormatter = {
    let formatter: NSDateFormatter = NSDateFormatter()
    formatter.dateStyle = .NoStyle
    formatter.timeStyle = .ShortStyle
    formatter.locale = Hyber.currentLocale
    return formatter
  }()
  
  public let dateFormatter: NSDateFormatter = {
    let formatter: NSDateFormatter = NSDateFormatter()
    formatter.dateStyle = .NoStyle
    formatter.timeStyle = .ShortStyle
    formatter.locale = Hyber.currentLocale
    return formatter
  }()
  
  private let moreThanAYearAgo = "MMMdyyyy"
  private let moreThanAWeekAgo = "EEEdMMM"
  private let moreThanTwoDaysAgo = "EEEE"
  
  /**
   Configures formatter
   
   - parameter date: date
   */
  public func configureDateFormatterWithDate(date: NSDate) {
    let components = NSCalendar.autoupdatingCurrentCalendar().components(
      [.Year, .Day],
      fromDate: date.startOfDay(),
      toDate: NSDate().startOfDay(),
      options: [NSCalendarOptions.WrapComponents])
    dateFormatter.dateStyle = .NoStyle
    dateFormatter.timeStyle = .NoStyle
    dateFormatter.doesRelativeDateFormatting = false
    if components.year > 0 {
      dateFormatter.setLocalizedDateFormatFromTemplate(moreThanAYearAgo)
      dateFormatter.dateFormat = dateFormatter.dateFormat + ","
    } else if components.day > 7 {
      dateFormatter.setLocalizedDateFormatFromTemplate(moreThanAWeekAgo)
      dateFormatter.dateFormat = dateFormatter.dateFormat + ","
    } else if components.day > 2 && components.day <= 7 {
      dateFormatter.setLocalizedDateFormatFromTemplate(moreThanTwoDaysAgo)
      dateFormatter.dateFormat = dateFormatter.dateFormat
    } else {
      dateFormatter.dateStyle = .LongStyle
      dateFormatter.doesRelativeDateFormatting = true
    }
  }
  
  /**
   Converts passed `date` to `NSAttributedString`
   
   - parameter date: `NSDate`
   
   - returns: Attributed string from passed date
   */
  public func attributedString(date: NSDate) -> NSAttributedString {
    
    configureDateFormatterWithDate(date)
    
    let dateString = dateFormatter.stringFromDate(date)
    let dateAttributedString = attributedString(dateString)
    
    let timeString = " " + timeFormatter.stringFromDate(date)
    let timeAttributedString = timeLabelStyle?.attributedString(timeString) ?? attributedString(timeString)
    
    let timeLabelString = NSMutableAttributedString(attributedString: dateAttributedString)
    timeLabelString.appendAttributedString(timeAttributedString)
    
    return timeLabelString
    
  }
  
}

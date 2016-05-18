//
//  NSDate+DayBoundaries.swift
//  Hyber
//
//  Created by Vitalii Budnik on 1/25/16.
//
//

import Foundation

/**
 Adds ability to get start of day and end of day `NSDate`s
 */
internal extension NSDate {
  
  /**
   Returns a new `NSDate` object pointing to beginning of a day, containing in `self`.
   - returns: A new `NSDate` object pointing to beginning of a day, containing in `self`.
   */
  func startOfDay() -> NSDate {
    return NSCalendar.autoupdatingCurrentCalendar().startOfDayForDate(self)
  }
  
  /**
   Returns a new `NSDate` object pointing to beginning of a previous day, containing in `self`.
   - returns: A new `NSDate` object pointing to beginning of a previous day, containing in `self`.
   */
  func previousDay() -> NSDate {
    let components = NSDateComponents()
    components.second = -1
    return NSCalendar.autoupdatingCurrentCalendar()
      .dateByAddingComponents(components, toDate: startOfDay(), options: [])!
  }
  
  /**
   Returns a new `NSDate` object pointing to end of a day, containing in `self`.
   - returns: A new `NSDate` object pointing to end of a day, containing in `self`.
   */
  func endOfDay() -> NSDate {
    let components = NSDateComponents()
    components.day = 1
    components.second = -1
    return NSCalendar.autoupdatingCurrentCalendar()
      .dateByAddingComponents(components, toDate: startOfDay(), options: [])!
  }
  
}

/**
 Compares two `NSDate`s by `timeIntervalSinceReferenceDate` equality
 - Parameter lhs: first `NSDate`
 - Parameter rhs: second `NSDate`
 - Returns: `true` if `timeIntervalSinceReferenceDate` of both dates is equal, `false` otherwise
 */
@warn_unused_result func == (lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs.timeIntervalSinceReferenceDate == rhs.timeIntervalSinceReferenceDate
}

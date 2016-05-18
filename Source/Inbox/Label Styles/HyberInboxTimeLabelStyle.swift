//
//  HyberInboxTimeLabelStyle.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/22/16.
//
//

import Foundation
import UIKit

/**
 Hyber Inbox Time Label Style
 */
public struct HyberInboxTimeLabelStyle: HyberTimeLabelStyle {
  
  /// Label font
  public var font: UIFont
  /// Label color
  public var color: UIColor
  
  public let timeFormatter: NSDateFormatter = {
    let formatter: NSDateFormatter = NSDateFormatter()
    formatter.dateStyle = .NoStyle
    formatter.timeStyle = .ShortStyle
    formatter.locale = Hyber.currentLocale
    return formatter
  }()
  
}

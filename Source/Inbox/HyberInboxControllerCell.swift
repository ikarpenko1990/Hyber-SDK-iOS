//
//  HyberInboxControllerCell.swift
//  Hyber
//
//  Created by Vitalii Budnik on 5/18/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation
import UIKit

/// Hyber Inbox View Controllers's cell
public class HyberInboxControllerCell: UITableViewCell {
  private var _inboxStyle: HyberInboxControllerStyle?
  private var styleDidChangeObserver: NSObjectProtocol? = .None
  private var styleDidChangeLocalizationObserver: NSObjectProtocol? = .None
  
  /// Inbox style
  public var inboxStyle: HyberInboxControllerStyle {
    get {
      if let inboxStyle = _inboxStyle {
        return inboxStyle
      }
      return sharedInboxStyle
    }
    set {
      guard !(_inboxStyle === newValue) else { return }
      removeInboxStyleNotificationsObservers(inboxStyle)
      _inboxStyle = newValue
      addInboxStyleNotificationsObservers()
      updateStyle(newValue)
      updateLocalization(newValue)
    }
  }
  
  func addInboxStyleNotificationsObservers() {
    
    styleDidChangeObserver = NSNotificationCenter.defaultCenter().addObserverForName(
      HyberInboxStyleDidChangeNotification,
      object: inboxStyle,
      queue: NSOperationQueue.mainQueue()) { (notification) in
        self.updateStyle(notification.object as? HyberInboxControllerStyle)
    }
    
    styleDidChangeLocalizationObserver = NSNotificationCenter.defaultCenter().addObserverForName(
      HyberInboxStyleDidChangeLocalizationNotification,
      object: inboxStyle,
      queue: NSOperationQueue.mainQueue()) { (notification) in
        self.updateLocalization(notification.object as? HyberInboxControllerStyle)
    }
    
  }
  
  func removeInboxStyleNotificationsObservers(object: HyberInboxControllerStyle?) {
    styleDidChangeObserver = .None
    styleDidChangeLocalizationObserver = .None
  }
  
  deinit {
    if let styleDidChangeObserver = styleDidChangeObserver {
      NSNotificationCenter.defaultCenter().removeObserver(styleDidChangeObserver)
      self.styleDidChangeObserver = .None
    }
    if let styleDidChangeLocalizationObserver = styleDidChangeLocalizationObserver {
      NSNotificationCenter.defaultCenter().removeObserver(styleDidChangeLocalizationObserver)
      self.styleDidChangeLocalizationObserver = .None
    }
  }
  
  func updateStyle(style: HyberInboxControllerStyle?) {
    
  }
  
  func updateLocalization(inboxStyle: HyberInboxControllerStyle?) {
    
  }
  
    /// Cell data
  public private (set) var cellData: HyberInboxCellData? = nil
  
  /**
   Configures cell with cell data
   
   - parameter cellData: cell `HyberInboxCellData`
   */
  public func configure(cellData: HyberInboxCellData) {
    self.cellData = cellData
  }
  
}

//
//  HyberBubbleTableViewCell.swift
//  Hyber
//
//  Created by Vitalii Budnik on 3/31/16.
//
//

import Foundation
import UIKit

/// bubbleViewStyleDidChange
public protocol InboxStyleDelegate: class {
  /**
   Notifcates the delegate, that bubble view style changed
   */
  func bubbleViewStyleDidChange()
}

//
//  HyberInboxControllerStyle.swift
//  Hyber
//
//  Created by Vitalii Budnik on 5/18/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation
import UIKit

/// Inbox controller style
public protocol HyberInboxControllerStyle: class {
  
  /// Bubble view style **type**
  var bubbleStyleType: HyberBubbleViewStyle.Type { get }
  
  /// Bubble corner radius
  var cornerRadius: CGFloat { get }
  
  /// Show avatar - `true`, or not - `false`
  var showAvatar: Bool { get }
  /// Show sender title - `true`, or not - `false`
  var showSenderTitle: Bool { get }
  /// Show message type as text - `true`, or not - `false`
  var showMessageTypeAsText: Bool { get }
  
  /// Bubble cell labels styles
  var labelsStyles: HyberLabelsStyles { get }
  
  /// Bubble styles for all known `HyberMessageType`s
  var bubbleStyles: [HyberMessageType: HyberBubbleViewStyle] { get }
  
  /**
   Creates new `HyberInboxControllerStyle`
   
   - parameter bubbleStyleType: Bubble view style **type**
   - parameter cornerRadius: Bubble corner radius
   - parameter showAvatar: Show avatar - `true`, or not - `false`
   - parameter showSenderTitle: Show sender title - `true`, or not - `false`
   - parameter showMessageTypeAsText: Show message type as text - `true`, or not - `false`
   
   - returns: New `HyberInboxControllerStyle`
   */
  init(
    bubbleStyleType: HyberBubbleViewStyle.Type,
    cornerRadius: CGFloat,
    showAvatar: Bool,
    showSenderTitle: Bool,
    showMessageTypeAsText: Bool)
  
  /**
   Returns default `HyberBubbleViewStyle`
   
   - returns: Default `HyberBubbleViewStyle`
   */
  func defaultBubbleStyle() -> HyberBubbleViewStyle
  
  /**
   Returns bubble style for passed `source`
   
   - parameter source: `HyberMessageData`
   
   - returns: Returns `HyberMessageData` for passed `source`
   */
  func bubbleStyle(source: HyberMessageData) -> HyberBubbleViewStyle
  
  /**
   Returns `UIImage` for passed `HyberMessageData`. `nil` if image not found
   
   - parameter source: `HyberMessageData`, for which you need `UIImage`
   
   - returns: `UIImage` for passed `HyberMessageData`. `nil` if image not found
   */
  func senderAvatarImage(source: HyberMessageData) -> UIImage?
  
}

extension HyberInboxControllerStyle {
  
  /**
   Returns bubble style for passed `source`
   
   - parameter source: `HyberMessageData`
   
   - returns: Returns `HyberMessageData` for passed `source`
   */
  public func bubbleStyle(source: HyberMessageData) -> HyberBubbleViewStyle {
    
    return bubbleStyles[source.type] ?? defaultBubbleStyle()
    
  }
  
  /**
   Returns default `HyberBubbleViewStyle`
   
   - returns: Default `HyberBubbleViewStyle`
   */
  public func defaultBubbleStyle() -> HyberBubbleViewStyle {
    
    return bubbleStyleType.defaultStyle()
    
  }
  
}

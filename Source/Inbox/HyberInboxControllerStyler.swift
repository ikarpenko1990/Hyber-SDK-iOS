//
//  HyberInboxControllerStyler.swift
//  Hyber
//
//  Created by Vitalii Budnik on 5/18/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation
import UIKit

/// Hyber InboxController Styler
public class HyberInboxControllerStyler: HyberInboxControllerStyle {
  
  public typealias LabelsStylesClass = HyberInboxLabelsStyles
  
  /// Bubble corner radius
  public let cornerRadius: CGFloat
  
  /// Show avatar - `true`, or not - `false`
  public let showAvatar: Bool
  /// Show sender title - `true`, or not - `false`
  public let showSenderTitle: Bool
  /// Show message type as text - `true`, or not - `false`
  public let showMessageTypeAsText: Bool
  
  /// Bubble cell labels styles
  public var labelsStyles: HyberLabelsStyles {
    didSet {
      notificateInboxStyleDidChange()
    }
  }
  
  /// Bubble styles for all known `HyberMessageType`s
  public var bubbleStyles: [HyberMessageType: HyberBubbleViewStyle] {
    didSet {
      notificateInboxStyleDidChange()
    }
  }
  
  private func notificateInboxStyleDidChange() {
    NSNotificationCenter.defaultCenter().postNotificationName(
      HyberInboxStyleDidChangeNotification,
      object: self)
  }
  
  private var contentSizeCategoryDidChangeObserver: NSObjectProtocol? = .None
  private var localizationDidChangeObserver: NSObjectProtocol? = .None
  
  /// Bubble view style **type**
  public let bubbleStyleType: HyberBubbleViewStyle.Type
  
  /**
   Creates new `HyberInboxControllerStyle`
   
   - parameter bubbleStyleType: Bubble view style **type**
   - parameter cornerRadius: Bubble corner radius
   - parameter showAvatar: Show avatar - `true`, or not - `false`
   - parameter showSenderTitle: Show sender title - `true`, or not - `false`
   - parameter showMessageTypeAsText: Show message type as text - `true`, or not - `false`
   
   */
  public required init(
    bubbleStyleType: HyberBubbleViewStyle.Type = HyberInboxBubbleViewStyle.self,
    cornerRadius: CGFloat = 10.0,
    showAvatar: Bool = true,
    showSenderTitle: Bool = true,
    showMessageTypeAsText: Bool = true) // swiftlint:disable:this opening_brace
  {
    
    self.cornerRadius = cornerRadius
    self.showAvatar = showAvatar
    self.showSenderTitle = showSenderTitle
    self.showMessageTypeAsText = showMessageTypeAsText
    self.bubbleStyleType = bubbleStyleType
    
    bubbleStyles = bubbleStyleType.allBubbleStyles()
    
    labelsStyles = LabelsStylesClass.init()
    
    contentSizeCategoryDidChangeObserver = NSNotificationCenter.defaultCenter().addObserverForName(
      UIContentSizeCategoryDidChangeNotification,
      object: .None,
      queue: .None) { _ in
        self.contentSizeCategoryDidChange()
    }
    
    localizationDidChangeObserver = NSNotificationCenter.defaultCenter().addObserverForName(
      HyberLocalizationDidChangeNotification,
      object: .None,
      queue: .None) { _ in
        self.localizationDidChange()
    }
    
    imagesCache.countLimit = 150 // 150 images
    imagesCache.totalCostLimit = 25 * 1024 * imagesCache.countLimit // 25Kb per image = 3.6Mb
    
  }
  
  func localizationDidChange() {
    labelsStyles.setLocale(Hyber.currentLocale)
    LocalizedStrings.UIKit.bundle = Hyber.localizedBundle(
      NSBundle(forClass: UILabel.self),
      language: Hyber.currentLocale.localeIdentifier)
    NSNotificationCenter.defaultCenter().postNotificationName(
      HyberInboxStyleDidChangeLocalizationNotification,
      object: self)
  }
  
  deinit {
    if let contentSizeCategoryDidChangeObserver = contentSizeCategoryDidChangeObserver {
      NSNotificationCenter.defaultCenter().removeObserver(contentSizeCategoryDidChangeObserver)
      self.contentSizeCategoryDidChangeObserver = .None
    }
    if let localizationDidChangeObserver = localizationDidChangeObserver {
      NSNotificationCenter.defaultCenter().removeObserver(localizationDidChangeObserver)
      self.localizationDidChangeObserver = .None
    }
  }
  
  let imagesCache: NSCache = NSCache()
  private var senderTitlesWithoutImage = [String]()
  /**
   Returns `UIImage` for passed `HyberMessageData`. `nil` if image not found
   
   - parameter source: `HyberMessageData`, for which you need `UIImage`
   
   - returns: `UIImage` for passed `HyberMessageData`. `nil` if image not found
   */
  public func senderAvatarImage(source: HyberMessageData) -> UIImage? {
    
    guard !source.sender.isEmpty else { return .None }
    
    let senderTitle = source.sender
    
    if let avatarImage = imagesCache.objectForKey(senderTitle) as? UIImage {
      return avatarImage
    } else if synchronized(.None, closure: { return self.senderTitlesWithoutImage.contains(senderTitle) }) {
      return .None
    }
    
    let imageName = "hivc_sender_" + senderTitle
    
    let avatarImage: UIImage?
    if let mainBundleImage = UIImage(named: imageName) {
      avatarImage = mainBundleImage
    } else if let frameworkBundleImage = UIImage(
      named: imageName,
      inBundle: Hyber.nonLocalizedBundle,
      compatibleWithTraitCollection: .None) {
      avatarImage = frameworkBundleImage
    } else {
      avatarImage = .None
    }
    
    if let avatarImage = avatarImage {
      imagesCache.setObject(avatarImage, forKey: senderTitle)
    } else {
      synchronized(.None, wait: false) { self.senderTitlesWithoutImage.append(senderTitle) }
    }
    
    return avatarImage
  }
  
  func contentSizeCategoryDidChange() {
    
    labelsStyles = LabelsStylesClass()
    
  }
  
}

/// Hyber `InboxStyle` did change localization notification name
public let HyberInboxStyleDidChangeLocalizationNotification = //swiftlint:disable:this variable_name
"com.gms-worldwide.Hyber.InboxStyleDidChangeLocalizationNotification"

/// Hyber `InboxStyle` did change notification name
public let HyberInboxStyleDidChangeNotification = //swiftlint:disable:this variable_name
"com.gms-worldwide.Hyber.InboxStyleDidChangeNotification"

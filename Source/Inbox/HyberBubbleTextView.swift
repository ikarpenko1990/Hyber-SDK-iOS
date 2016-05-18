//
//  HyberBubbleTextView.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/15/16.
//
//

import Foundation
import UIKit

/// The delegate of `BubbleTextView`
protocol HyberBubbleTextViewDelegate: class {
  /**
   Asks the delegate to enter editing mode
   
   - parameter view: The `BubbleTextView` object requesting editing mode
   */
  func bubbleTextViewWillEnterEditingMode(view: HyberBubbleTextView)
}

internal struct LocalizedStrings {
  
  static var more: String {
    return Hyber.bundle.localizedStringForKey(
      "MORE...",
      value: .None,
      table: "HyberInboxController")
  }
  
  static var all: String {
    return Hyber.bundle.localizedStringForKey(
      "ALL",
      value: .None,
      table: "HyberInboxController")
  }
  
  static var deleteAll: String {
    return Hyber.bundle.localizedStringForKey(
      "DELETE ALL",
      value: .None,
      table: "HyberInboxController")
  }
  
  struct UIKit {
    
    static var bundle = Hyber.localizedBundle(
      NSBundle(forClass: UILabel.self),
      language: Hyber.currentLocale.localeIdentifier)
    
    static var copy: String {
      return bundle.localizedStringForKey(
        "Copy",
        value: .None,
        table: .None)
    }
    
    static var cancel: String {
      return bundle.localizedStringForKey(
        "Cancel",
        value: .None,
        table: .None)
    }
    
    static var search: String {
      return bundle.localizedStringForKey(
        "Search",
        value: .None,
        table: .None)
    }
    
  }
}

/// `UITextView` with bubble border
public class HyberBubbleTextView: UITextView, UITextViewDelegate {
  
  // Custom layer `BubbleLayer`
  override public static func layerClass() -> AnyClass {
    return HyberBubbleLayer.self
  }
  
  /// The color used to fill the bubble shape
  internal var bubbleColor: UIColor? {
    get {
      guard let bubbleColor = (layer as! HyberBubbleLayer).fillColor else {//swiftlint:disable:this force_cast
        return .None
      }
      return UIColor(CGColor: bubbleColor)
    }
    set {
      (layer as! HyberBubbleLayer).fillColor = newValue?.CGColor //swiftlint:disable:this force_cast
    }
  }
  
  /// `UILongPressGestureRecognizer`
  private weak var longPressGestureRecognizer: UILongPressGestureRecognizer! {
    willSet {
      if longPressGestureRecognizer != nil {
        removeGestureRecognizer(longPressGestureRecognizer)
      }
    }
    didSet {
      addGestureRecognizer(longPressGestureRecognizer)
    }
  }
  
  override public var userInteractionEnabled: Bool {
    willSet {
      resignFirstResponder()
    }
  }
  
  // MARK: - UIView Lifecycle
  
  required public init?(coder aDecoder: NSCoder) { //swiftlint:disable:this missing_docs
    super.init(coder: aDecoder)
    setupLongPressGestureRecognizer()
  }
  
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    setupLongPressGestureRecognizer()
  }
  
  deinit {
    longPressGestureRecognizer.removeTarget(self, action: #selector(longTapDetected(_:)))
    NSNotificationCenter.defaultCenter().removeObserver(
      self,
      name: UIMenuControllerWillHideMenuNotification,
      object: nil)
  }
  
  /**
   Configures `UILongPressGestureRecognizer` of `self`
   */
  private func setupLongPressGestureRecognizer() {
    let longPressGestureRecognizer = UILongPressGestureRecognizer(
      target: self,
      action: #selector(longTapDetected(_:)))
    longPressGestureRecognizer.minimumPressDuration = 0.5
    longPressGestureRecognizer.cancelsTouchesInView = false
    longPressGestureRecognizer.allowableMovement = 40.0
    longPressGestureRecognizer.numberOfTapsRequired = 0
    longPressGestureRecognizer.numberOfTouchesRequired = 1
    
    self.longPressGestureRecognizer = longPressGestureRecognizer
    
    addGestureRecognizer(longPressGestureRecognizer)
  }
  /**
   The receiver’s delegate. Delegates `more` action menu was choosen
  */
  weak var bubbleTextViewDelegate: HyberBubbleTextViewDelegate? = .None
  
}

class HyberBubbleTextViewMenuController: UIMenuController {
  
  override init() {
    super.init()
    
    localizationDidChangeObserver = NSNotificationCenter.defaultCenter().addObserverForName(
      HyberLocalizationDidChangeNotification,
      object: .None,
      queue: NSOperationQueue.mainQueue()) { (notification) in
        self.updateLocalization()
    }
    
    updateLocalization()
  }
  
  var localizationDidChangeObserver: NSObjectProtocol? = .None
  
  deinit {
    if let localizationDidChangeObserver = localizationDidChangeObserver {
      NSNotificationCenter.defaultCenter().removeObserver(localizationDidChangeObserver)
      self.localizationDidChangeObserver = .None
    }
  }
  
  func updateLocalization() {
    menuItems = [
      UIMenuItem(
        title: LocalizedStrings.UIKit.copy,
        action: NSSelectorFromString("customCopy:")),
      UIMenuItem(
        title: LocalizedStrings.more,
        action: NSSelectorFromString("more:"))
    ]
  }
  
  private static var SharedBubbleTextViewMenuControllerHandle: UInt8 = 0
  override class func sharedMenuController() -> HyberBubbleTextViewMenuController {
    
    let sharedMenuController = objc_getAssociatedObject(
      self,
      &SharedBubbleTextViewMenuControllerHandle) as? HyberBubbleTextViewMenuController
    
    if let sharedMenuController = sharedMenuController {
      return sharedMenuController
    }
    
    let newSharedMenuController = HyberBubbleTextViewMenuController()
    objc_setAssociatedObject(
      self,
      &SharedBubbleTextViewMenuControllerHandle,
      newSharedMenuController,
      .OBJC_ASSOCIATION_RETAIN)
    
    return newSharedMenuController
    
  }
  
}

// MARK: - Menu
extension HyberBubbleTextView {
  
  /**
   Notification handler for `UIMenuController UIMenuControllerWillHideMenuNotification`
   
   - parameter notification: `NSNotification` info
   */
  @objc private func menuControllerWillHideMenu(notification: NSNotification) {
    resignFirstResponder()
  }
  
  /**
   Handler of long tap action. Shows shared `UIMenuController` if needed
   
   - parameter sender: `UILongPressGestureRecognizer`, that sended action
   */
  @objc private func longTapDetected(sender: UILongPressGestureRecognizer) {
    let menu = HyberBubbleTextViewMenuController.sharedMenuController()
    var menuRect = self.frame
    menuRect.origin.y += 5
    if !self.isFirstResponder() {
      self.becomeFirstResponder()
    }
    if !menu.menuVisible {
      menu.setTargetRect(menuRect, inView: self)
      menu.setMenuVisible(true, animated: true)
    }
  }

}

// MARK: - UIGestureRecognizers
extension HyberBubbleTextView {
  
  override public func addGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
    
    if longPressGestureRecognizer != nil && gestureRecognizer == longPressGestureRecognizer {
      // custom UILongPressGestureRecognizer for menu
      super.addGestureRecognizer(gestureRecognizer)
      
    } else if let _ = gestureRecognizer as? UIPanGestureRecognizer {
      // Scrolling
      super.addGestureRecognizer(gestureRecognizer)
      
    } else if let tapGesture = gestureRecognizer as? UITapGestureRecognizer {
      // Tap
      if tapGesture.numberOfTapsRequired != 2 {
        // not double tap
        super.addGestureRecognizer(tapGesture)
      }
      
    } else if let longPressGestureRecognizer = gestureRecognizer as? UILongPressGestureRecognizer {
      // Long press
      if longPressGestureRecognizer.minimumPressDuration != 0.5 {
        // Loupe gesture
        super.addGestureRecognizer(longPressGestureRecognizer)
      }
      
    } else {
      let gestureRecognizerClassName = String(gestureRecognizer.dynamicType)
      if gestureRecognizerClassName == "UITapAndAHalfRecognizer" {
        //swiftlint:disable line_length
        // tap and hold -> https://github.com/nst/iOS-Runtime-Headers/blob/master/Frameworks/UIKit.framework/UITapAndAHalfRecognizer.h
        //swiftlint:enable line_length
        return
      }
      super.addGestureRecognizer(gestureRecognizer)
    }
    
  }
  
}

// MARK: - UIResponser
// MARK: UIResponser. Become, resign
extension HyberBubbleTextView {
    
  override public func becomeFirstResponder() -> Bool {
    
    guard !isFirstResponder() else { return true }
    
    let becomeFirstResponder = super.becomeFirstResponder()
    
    if becomeFirstResponder {
      NSNotificationCenter.defaultCenter().addObserver(
        self,
        selector: #selector(menuControllerWillHideMenu(_:)),
        name: UIMenuControllerWillHideMenuNotification,
        object: HyberBubbleTextViewMenuController.sharedMenuController())
      bubbleColor = bubbleColor?.darker()
    }
    
    return becomeFirstResponder
  }

  override public func resignFirstResponder() -> Bool {
    
    guard isFirstResponder() else { return true }
    
    let resignFirstResponder = super.resignFirstResponder()
    
    if resignFirstResponder {
      NSNotificationCenter.defaultCenter().removeObserver(
        self,
        name: UIMenuControllerWillHideMenuNotification,
        object: HyberBubbleTextViewMenuController.sharedMenuController())
      bubbleColor = bubbleColor?.lighter()
    }
    
    return resignFirstResponder
    
  }
}

// MARK: UIResponser. Actions
extension HyberBubbleTextView {
  
  override public func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
    if action == #selector(customCopy(_:)) {
      return true
    }
    if action == #selector(more(_:)) {
      return true
    }
    
    return false
  }
  
  /**
   Copies contents of `self` to the pasteboard.
   
   At fisrt selects all objects in the current view. Than invokes `copy` method of `super`class.
   And cancels selection.
   
   This method is invoked when the user taps the Copy command of the editing menu. 
   A subclass of UIResponder typically implements this method. Using the methods of the UIPasteboard class, 
   it should convert the selection into an appropriate object (if necessary) and write 
   that object to a pasteboard. The command travels from the first responder up the responder chain until it 
   is handled; it is ignored if no responder handles it. If a responder doesn’t handle the command 
   in the current context, it should pass it to the next responder.
   
   - parameter sender: The object calling this method.
   */
   @objc public func customCopy(sender: AnyObject?) {
    self.selectAll(sender)
    super.copy(sender)
    self.selectedRange = NSRange.init(location: 0, length: 0)
  }
  
  /**
   Copy the selection to the pasteboard.
   This method is invoked when the user taps the More command of the editing menu.
   
   - parameter sender: The object calling this method.
   */
  @objc public func more(sender: AnyObject?) {
    resignFirstResponder()
    bubbleTextViewDelegate?.bubbleTextViewWillEnterEditingMode(self)
  }
  
}

//
//  HyberInboxControllerMessageCell.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/6/16.
//
//

import Foundation
import UIKit
import QuartzCore

let sharedInboxStyle = HyberInboxControllerStyler()

/// Hyber Inbox Controller Message Cell
public class HyberInboxControllerMessageCell: HyberInboxControllerCell {
  
  override func updateLocalization(inboxStyle: HyberInboxControllerStyle?) {
    
    let inboxStyle = inboxStyle ?? self.inboxStyle
    
    let labelsStyles = inboxStyle.labelsStyles
    
    timeLabelMaxWidth = labelsStyles.timeLabelStyle.maxTimeWidth()
    
    setupTimeLabel(inboxStyle, cellData: cellData)
    
  }
  
  override func updateStyle(inboxStyle: HyberInboxControllerStyle?) {
    
    let inboxStyle = inboxStyle ?? self.inboxStyle
    
    let labelsStyles = inboxStyle.labelsStyles
    
    timeLabel.textColor = labelsStyles.timeLabelStyle.color
    timeLabel.font = labelsStyles.timeLabelStyle.font
    
    textView.font = labelsStyles.messageLabelStyle.font
    
    if textView.layer.cornerRadius != inboxStyle.cornerRadius {
      
      textView.layer.cornerRadius = inboxStyle.cornerRadius
      
      avatarImageView.layer.cornerRadius = inboxStyle.cornerRadius
      
      let avatarImage = self.avatarImage
      self.avatarImage = avatarImage
      
      textView.textContainerInset = UIEdgeInsets(
        top: ceil(textView.layer.cornerRadius * 0.5),
        left: ceil(textView.layer.cornerRadius * 1.0),
        bottom: ceil(textView.layer.cornerRadius * 0.75),
        right: ceil(textView.layer.cornerRadius * 0.5))
      
    }
    
  }
  
  public required init?(coder aDecoder: NSCoder) { //swiftlint:disable:this missing_docs
    super.init(coder: aDecoder)
    
    configureBackgroundView()
  }
  
  func configureBackgroundView() {
    let viewWithClearBackground = UIView()
    viewWithClearBackground.backgroundColor = UIColor.clearColor()
    selectedBackgroundView = viewWithClearBackground
  }
  
  private let timeLabelMaxOffset: CGFloat = 30
  
  func setTimeLabelOffset(timeLabelOffset: CGFloat, animated: Bool) {
    
//    var x: CGFloat = 0.0
//    var xx: CGFloat = 0.0
    if !(self.timeLabel.layer.animationKeys()?.isEmpty ?? true) {
//      let currentLayer = self.timeLabel.layer.presentationLayer()
      self.timeLabel.layer.removeAllAnimations()
//      if let currentLayer = currentLayer as? CALayer {
//        x = round(currentLayer.frame.maxX - (bounds.width + timeLabelMaxOffset))
//        xx = currentLayer.frame.origin.x
//      }
    }
    UIView.animateWithDuration(
      animated ? 0.5 : 0,
      delay: animated ? 0.5 : 0,
      options: [],
      animations: { [weak self] in
        
        self?.timeLabelOffset = timeLabelOffset
        if animated {
          self?.layoutIfNeeded()
        }
      },
      completion: { (finished) in
        if !finished {
          
          var x: CGFloat = 0.0
          var xx: CGFloat = 0.0
          let currentLayer = self.timeLabel.layer.presentationLayer()
          if let currentLayer = currentLayer as? CALayer {
            x = round(currentLayer.frame.maxX - (self.bounds.width + self.timeLabelMaxOffset))
            xx = currentLayer.frame.origin.x
          }
          
          self.timeLabelOffset = x
          if x != 0 {
            self.timeLabel.frame.origin.x = xx
            self.setNeedsLayout()
            self.layoutIfNeeded()
          }
        }
    })
  }
  
  var timeLabelOffset: CGFloat {
    get {
      guard timeLabelLeadingConstraint != nil else { return timeLabelMaxOffset }
      return timeLabelLeadingConstraint.constant - timeLabelMaxOffset
    }
    set {
      let value: CGFloat
      if newValue >= 0 {
        value = timeLabelMaxOffset
      } else {
        value = max(newValue / 1.5 + timeLabelMaxOffset, (-timeLabelMaxWidth - timeLabelMaxOffset))
      }
      timeLabelLeadingConstraint.constant = value
    }
  }
  
  @IBOutlet var timeLabelWidthConstraint: NSLayoutConstraint!
  @IBOutlet private var timeLabelLeadingConstraint: NSLayoutConstraint! {
    didSet {
      timeLabelLeadingConstraint.constant = timeLabelMaxOffset
    }
  }
  
  override public func setSelected(selected: Bool, animated: Bool) {
    guard self.selected != selected else { return }
    super.setSelected(selected, animated: animated)
    if selected {
      selectedBackgroundView?.backgroundColor = UIColor.whiteColor()
      backgroundView?.backgroundColor = UIColor.whiteColor()
      backgroundColor = UIColor.whiteColor()
    }
  }
  
  @IBOutlet private var timeLabel: UILabel! {
    didSet {
      timeLabel.clipsToBounds = false
    }
  }
  
  var timeLabelMaxWidth: CGFloat = 52.0 {
    didSet {
      let timeLabelOffset = self.timeLabelOffset
      self.timeLabelOffset = timeLabelOffset
      timeLabelWidthConstraint.constant = timeLabelMaxWidth
      setupTrailingConstraint(_editing)
    }
  }
  
  @IBOutlet private (set) var textView: HyberBubbleTextView! {
    didSet {
      textView.clipsToBounds = false
      
      textView.bubbleTextViewDelegate = self
    }
  }
  
  @IBOutlet private var trailingConstraint: NSLayoutConstraint!
  
  func trailingConstantOffset(editing: Bool) -> CGFloat {
    let offset = min(-38.0, -timeLabelMaxWidth)
    return editing ? 38.0 + offset : offset
  }
  
  private var _editing: Bool = false
  override public func setEditing(editing: Bool, animated: Bool) {
    guard _editing != editing else { return }
    _editing = editing
    
    textView.userInteractionEnabled = !editing
    
    UIView.animateWithDuration(animated ? 0.3 : 0.0) { [weak self] in
      self?.setupTrailingConstraint(editing)
    }
    
    super.setEditing(editing, animated: animated)
    
  }
  
  @IBOutlet var avatarImageViewSizeConstraint: NSLayoutConstraint! //{
  
  @IBOutlet var avatarImageView: UIImageView! {
    didSet {
      avatarImageView.layer.cornerRadius = inboxStyle.cornerRadius
    }
  }
  
  var avatarImage: UIImage? {
    get {
      guard avatarImageView != nil else { return .None }
      return avatarImageView.image
    }
    set {
      guard avatarImageView != nil else { return }
      
      let avatarImageViewSize: CGFloat = newValue == .None && !indentAvatar
        ? 0.0
        : inboxStyle.cornerRadius * 2.5
      
      if avatarImageViewSizeConstraint.constant != avatarImageViewSize {
        avatarImageViewSizeConstraint.constant = avatarImageViewSize
      }
      
      avatarImageView.image = newValue
      
    }
  }
  
  func configureAvatar(message: HyberMessageData, showAvatar: Bool) {
    
    guard showAvatar else { self.avatarImage = .None; return }
    
    let senderTitle = message.sender

    if senderTitle.isEmpty {
      self.avatarImage = .None
      return
    }
    
    self.avatarImage = inboxStyle.senderAvatarImage(message)
    
  }
  
  var indentAvatar: Bool = false {
    didSet {
      guard indentAvatar != oldValue else { return }
      avatarImageView.hidden = !indentAvatar
    }
  }
  
  func setupTrailingConstraint(editing: Bool) {
    
    let trailingConstantOffset = self.trailingConstantOffset(editing)
    if trailingConstraint.constant != trailingConstantOffset {
      trailingConstraint.constant = trailingConstantOffset
    }
    
  }
  
  func setupTimeLabel(style: HyberInboxControllerStyle, cellData: HyberInboxCellData? = .None) {
    
    setTimeLabelOffset(0, animated: false)
    setupTrailingConstraint(editing)
  
    guard let cellData = cellData, message = cellData.message else { return }
    
    timeLabel.text = style.labelsStyles.timeLabelStyle.timeFormatter.stringFromDate(
      message.deliveredDate)
  }
  
  public override func configure(cellData: HyberInboxCellData) {
    
    super.configure(cellData)
    
    let inboxStyle = self.inboxStyle
    
    guard let message = cellData.message else { return }
    
    let bubbleStyle = inboxStyle.bubbleStyle(message)

    textView.editable = true
    textView.textColor = bubbleStyle.textColor
    textView.bubbleColor = bubbleStyle.bubbleColor
    textView.text = message.messageBody
    textView.editable = false
    
    setupTimeLabel(inboxStyle, cellData: cellData)
    
    self.indentAvatar = cellData.indentAvatar || cellData.showAvatar
    configureAvatar(message, showAvatar: cellData.showAvatar)

  }
    
  weak var inboxCellDelegate: HyberInboxControllerMessageCellDelegate? = .None
  
}

/// The delegate of `InboxCell`
protocol HyberInboxControllerMessageCellDelegate: class {
  /**
   Asks the delegate to enter editing mode
   
   - parameter cell: The `InboxCell` object requesting editing mode
   */
  func inboxCellWillEnterEditingMode(cell: HyberInboxControllerMessageCell)
}

// MARK: - BubbleTextViewDelegate
extension HyberInboxControllerMessageCell: HyberBubbleTextViewDelegate {
  
  func bubbleTextViewWillEnterEditingMode(view: HyberBubbleTextView) {
    inboxCellDelegate?.inboxCellWillEnterEditingMode(self)
  }
  
}

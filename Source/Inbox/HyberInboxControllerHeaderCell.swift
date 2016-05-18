//
//  HedaderTableViewCell.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/11/16.
//
//

import Foundation
import UIKit

private let moreThanAYearAgo = "MMMdyyyy"
private let moreThanAWeekAgo = "EEEdMMM"
private let moreThanTwoDaysAgo = "EEE"

internal let editingViewWidth: CGFloat = 38.0

internal extension NSLocale {
  
  func is24HoursFormat() -> Bool {
    let formatter = NSDateFormatter()
    formatter.locale = self
    formatter.dateStyle = .NoStyle
    formatter.timeStyle = .ShortStyle
    let dateString = formatter.stringFromDate(NSDate())
    return !dateString.containsString(formatter.PMSymbol) && !dateString.containsString(formatter.AMSymbol)
  }
  
}

/// Hyber `InboxController` Header Cell
public class HyberInboxControllerHeaderCell: HyberInboxControllerCell {
  
  override func updateStyle(style: HyberInboxControllerStyle?) {
    
    let inboxStyle = self.inboxStyle
    let labelsStyles = inboxStyle.labelsStyles
    
//    timeLabel.font = labelsStyles.timeLabelStyle.font
//    timeLabel.textColor = labelsStyles.timeLabelStyle.color

    messageTypeLabel.font = labelsStyles.messageTypeLabelStyle.font
    messageTypeLabel.textColor = labelsStyles.messageTypeLabelStyle.color
    
    senderTitleLabel.font = labelsStyles.senderLabelStyle.font
    senderTitleLabel.textColor = labelsStyles.senderLabelStyle.color

    let corenrRadius = inboxStyle.cornerRadius
    let newConstant = corenrRadius * 1.25
      + ((cellData?.indentAvatar ?? false) ? corenrRadius * 2.0 : 0.0)
      + (_editing ? 38.0 : 0.0)
    
    guard senderTitleLabelLeagingConstraint.constant != newConstant else { return }
    senderTitleLabelLeagingConstraint.constant = newConstant
    
//    if animated {
//      layoutIfNeeded()
//    }
    
  }
  
//  static let styler: InboxStyle = InboxStyler()
  @IBOutlet private var messageTypeLabel: UILabel! {
    didSet {
    }
  }

  var _editing: Bool = false //swiftlint:disable:this variable_name
  func setEditingMode(editing: Bool, animated: Bool) {
    guard _editing != editing else { return }
    _editing = editing
    configureSenderTitleLabelLeagingConstraint(animated)
  }
  
  @IBOutlet var senderTitleLabelLeagingConstraint: NSLayoutConstraint!
  
  @IBOutlet private var timeLabel: UILabel! {
    didSet {
    }
  }
  
  @IBOutlet private var senderTitleLabel: UILabel! {
    didSet {
    }
  }
  
  private func configureTimeLabel(date: NSDate, showTime: Bool) {
    guard showTime else { timeLabel.text = .None; return }
    
    let inboxStyle = self.inboxStyle
    let labelsStyles = inboxStyle.labelsStyles
    
    let dateLabelStyle = labelsStyles.dateLabelStyle
    
    timeLabel.attributedText = dateLabelStyle.attributedString(date)
    
  }
  
  private func configureMessageTypeLabel(messageType: HyberMessageType, showMessageType: Bool) {
    guard showMessageType else { messageTypeLabel.text = .None; return }
    
    messageTypeLabel.text = messageType.description
    
  }
  
  private func configureSenderTitleLabel(senderTitle: String?, showSenderTitle: Bool) {
    guard showSenderTitle else { senderTitleLabel.text = .None; return }
    
    senderTitleLabel.text = senderTitle
    
    configureSenderTitleLabelLeagingConstraint(false)
    
  }
  
  
//  var indentAvatar: Bool = false
  func configureSenderTitleLabelLeagingConstraint(animated: Bool) {
    
    let corenrRadius = inboxStyle.cornerRadius
    let newConstant = corenrRadius * 1.25
      + ((cellData?.indentAvatar ?? false)
        ? corenrRadius * 2.0
        : 0.0)
      + (_editing ? 38.0 : 0.0)
    
    guard senderTitleLabelLeagingConstraint.constant != newConstant else { return }
    senderTitleLabelLeagingConstraint.constant = newConstant
    if animated {
      layoutIfNeeded()
    }
//    else {
//      setNeedsLayout()
//    }
  }
  
  override func updateLocalization(inboxStyle: HyberInboxControllerStyle?) {
    guard let cellData = cellData else { return }
    configure(cellData)
  }
  
  public override func configure(cellData: HyberInboxCellData) {
    super.configure(cellData)
    
    guard let message = cellData.message else { return }
    
    configureTimeLabel(message.deliveredDate, showTime: cellData.showTime)
    configureMessageTypeLabel(message.type, showMessageType: cellData.showMessageType)
    
//    self.indentAvatar = cellData.indentAvatar
    
    configureSenderTitleLabel(message.sender, showSenderTitle: cellData.showSenderTitle)

  }
  
}

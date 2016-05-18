//
//  HyberInboxLabelsStyles.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/22/16.
//
//

import Foundation
import UIKit

/// Hyber Inbox Labels Styles
public class HyberInboxLabelsStyles: HyberLabelsStyles {
  
  public let messageLabelStyle: HyberTextLabelStyle
  public let timeLabelStyle: HyberTimeLabelStyle
  public let dateLabelStyle: HyberDateTimeLabelStyle
  public let messageTypeLabelStyle: HyberTextLabelStyle
  public let senderLabelStyle: HyberTextLabelStyle
  
  public class func initLabelStyles()
    -> (
    messageLabelStyle: HyberTextLabelStyle,
    timeLabelStyle: HyberTimeLabelStyle,
    dateLabelStyle: HyberDateTimeLabelStyle,
    messageTypeLabelStyle: HyberTextLabelStyle,
    senderLabelStyle: HyberTextLabelStyle) //swiftlint:disable:this opening_brace
  {
    
    let messageLabelStyle = HyberInboxTextLabelStyle(
      font: UIFont.preferredFontForTextStyle(UIFontTextStyleBody),
      color: UIColor.whiteColor())
    
    let timeLabelStyle = HyberInboxTimeLabelStyle(
      font: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2),
      color: UIColor.grayColor())
    
    let dateLabelStyle = HyberInboxDateTimeLabelStyle(
      font: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2).boldFont,
      color: UIColor.grayColor(),
      timeLabelStyle: timeLabelStyle)
    
    
    let messageTypeLabelStyle = HyberInboxTextLabelStyle(
      font: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2).boldFont,
      color: UIColor.grayColor())
    
    let senderLabelStyle = HyberInboxTextLabelStyle(
      font: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2),
      color: UIColor.grayColor())
    
    return (messageLabelStyle: messageLabelStyle,
            timeLabelStyle: timeLabelStyle,
            dateLabelStyle: dateLabelStyle,
            messageTypeLabelStyle: messageTypeLabelStyle,
            senderLabelStyle: senderLabelStyle)
  }
  
  init() {
    
    let labelStyles = self.dynamicType.initLabelStyles()
    
    messageLabelStyle = labelStyles.messageLabelStyle
    timeLabelStyle = labelStyles.timeLabelStyle
    dateLabelStyle = labelStyles.dateLabelStyle
    messageTypeLabelStyle = labelStyles.messageTypeLabelStyle
    senderLabelStyle = labelStyles.senderLabelStyle
    
  }
  
}

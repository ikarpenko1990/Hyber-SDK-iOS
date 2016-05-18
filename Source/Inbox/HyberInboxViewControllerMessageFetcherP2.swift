//
//  HyberInboxViewControllerMessageFetcherP2.swift
//  Hyber
//
//  Created by Vitalii Budnik on 5/18/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation


extension HyberInboxViewControllerMessageFetcher {
  
  func shouldDisplayFlags(
    previousMessage: HyberMessageData?,
    _ currentMessage: HyberMessageData,
      _ nextMessage: HyberMessageData?)
    -> (shouldDisplayHeader: Bool,
    showTime: Bool,
    showMessageType: Bool,
    showSenderTitle: Bool,
    indentAvatar: Bool,
    showAvatar: Bool) //swiftlint:disable:this opening_brace
  {
    
    let shouldDisplayCurrentHeaderFlags = shouldDisplayHeaderFlags(previousMessage, currentMessage)
    
    let shouldDisplayNextHeaderFlags = shouldDisplayHeaderFlags(currentMessage, nextMessage)
    
    let shouldDisplayAvatar =
      shouldDisplayNextHeaderFlags.shouldDisplayHeader
        || currentMessage.sender != nextMessage?.sender
    
    let indentAvatar = styler.showAvatar && styler.senderAvatarImage(currentMessage) != .None
    return (
      shouldDisplayHeader: shouldDisplayCurrentHeaderFlags.shouldDisplayHeader,
      showTime: shouldDisplayCurrentHeaderFlags.showTime,
      showMessageType: shouldDisplayCurrentHeaderFlags.showMessageType,
      showSenderTitle: shouldDisplayCurrentHeaderFlags.showSenderTitle
        || (styler.showAvatar
          && !indentAvatar), // show sender title when should show avatar but no avatar image found
      indentAvatar: indentAvatar,
      showAvatar: indentAvatar && shouldDisplayAvatar)
  }
  
  func shouldDisplayHeaderFlags(
    previousMessage: HyberMessageData?,
    _ currentMessage: HyberMessageData?)
    -> (shouldDisplayHeader: Bool,
    showTime: Bool,
    showMessageType: Bool,
    showSenderTitle: Bool) //swiftlint:disable:this opening_brace
  {
    
    let shouldDisplayMessageType = previousMessage?.type != currentMessage?.type
      && styler.showMessageTypeAsText
    
    let shouldDisplayTime =
      (currentMessage?.deliveredDate.timeIntervalSinceDate(
        previousMessage?.deliveredDate
          ?? NSDate(timeIntervalSince1970: 0))
        ?? 0)
        > timeIntervalForHeaderTimeDisplay
    
    let shouldDisplaySenderTitle =
      (shouldDisplayMessageType
        || shouldDisplayTime
        || previousMessage?.sender != currentMessage?.sender)
        && styler.showSenderTitle
    
    let shouldDisplayHeader = shouldDisplayMessageType || shouldDisplayTime || shouldDisplaySenderTitle
    
    return (shouldDisplayHeader: shouldDisplayHeader,
            showTime: shouldDisplayTime,
            showMessageType: shouldDisplayMessageType,
            showSenderTitle: shouldDisplaySenderTitle)
    
  }
  
  /**
   `InboxViewControllerMessageFetcherResult` with `NSIndexPath`s objects, indicating
   what was deleted, added, or refreshed
   
   - parameter before: `Array<HyberInboxCellData>` before changes was made
   - parameter after: `Array<HyberInboxCellData>` after changes was made
   
   - returns: `InboxViewControllerMessageFetcherResult` with `NSIndexPath`s objects, indicating
   what was deleted, added, or refreshed
   */
  func diff(
    before: [HyberInboxCellData],
    after: [HyberInboxCellData])
    -> HyberInboxViewControllerMessageFetcherResult //swiftlint:disable:this opening_brace
  {
    
    let oldSet = Set<HyberInboxCellData>(before)
    let newSet = Set<HyberInboxCellData>(after)
    
    let allDeletedCellsData: Set<HyberInboxCellData> = oldSet.subtract(after)
    let deletedCellsData = allDeletedCellsData.filter { (deletedCellData) -> Bool in
      newSet.indexOf { $0 ~= deletedCellData } == .None
    }
    
    let allAdedCellsData: Set<HyberInboxCellData> = newSet.subtract(oldSet)
    let addedCellsData: [HyberInboxCellData] = allAdedCellsData.filter { (addedCellData) -> Bool in
      oldSet.indexOf { $0 ~= addedCellData } == .None
    }
    
    let reloadedCellsData: [HyberInboxCellData] = allDeletedCellsData.filter { (deletedCellData) -> Bool in
      allAdedCellsData.indexOf { $0 ~= deletedCellData } != .None
    }
    
    let deletedIndexPaths: [NSIndexPath] = deletedCellsData.map {
      return NSIndexPath(forRow: before.indexOf($0)!, inSection: 0)
      }.sort { $0.row < $1.row }
    
    let addedIndexPaths: [NSIndexPath] = addedCellsData.map {
      return NSIndexPath(forRow: after.indexOf($0)!, inSection: 0)
      }.sort { $0.row > $1.row }
    
    let reloadedIndexPaths: [NSIndexPath] = reloadedCellsData.map { reloadCellsData -> NSIndexPath in
      return NSIndexPath(forRow: before.indexOf(reloadCellsData)!, inSection: 0)
    }
    
    return HyberInboxViewControllerMessageFetcherResult(
      delete: deletedIndexPaths,
      add: addedIndexPaths,
      reload: reloadedIndexPaths)
    
  }

}



extension HyberInboxViewControllerMessageFetcher: SyncronizableOperationQueue {
  
}

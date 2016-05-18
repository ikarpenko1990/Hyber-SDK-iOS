//
//  HyberDataInboxMessage+Searchable.swift
//  Hyber
//
//  Created by Vitalii Budnik on 1/26/16.
//
//

import Foundation
import CoreData

extension HyberDataInboxMessage: NSManagedObjectSearchable {
  /**
   Sets `fetchedDate` into object
   - parameter deliveredDateDay: `NSTimeInterval` for date from 00:00:00 UTC on 1 January 2001.
   (optional. If not passed uses `self.deliveredDate`)
   */
  internal func setFethcedDate(deliveredDateDay: NSTimeInterval? = .None) {
    let newDeliveredDateDay: NSTimeInterval
    if let deliveredDateDay = deliveredDateDay {
      newDeliveredDateDay = deliveredDateDay
    } else {
      newDeliveredDateDay = NSDate(timeIntervalSinceReferenceDate: deliveredDate)
        .startOfDay()
        .timeIntervalSinceReferenceDate
    }
    if fetchedDate?.fetchedDate != newDeliveredDateDay {
      if let fetchedDate = HyberDataInboxFetchedDate.getHyberDataInboxFetchedDate(
        forDate: newDeliveredDateDay,
        inManagedObjectContext: managedObjectContext,
        createNewIfNotFound: true) // swiftlint:disable:this opening_brace
      {
        self.fetchedDate = fetchedDate
      }
    }
  }
  
  internal override func willSave() {
    
    let newDeliveredDateDay = NSDate(timeIntervalSinceReferenceDate: deliveredDate)
      .startOfDay()
      .timeIntervalSinceReferenceDate
    
    setFethcedDate(newDeliveredDateDay)
    
    super.willSave()
    
  }
  
  /**
   Makes `HyberMessage` struct for current object
   - returns: `HyberMessage` if sucessfuly converted, otherwise returns `nil`
   */
  func gmsMessage() -> HyberMessage? {
    return HyberMessage(message: self)
  }
  
  /**
   Sets new `String` with `senderName` to message
   - Parameter newSenderName: New aplha-name to be setted
   */
  func setSenderNameString(newSenderName: String?) {
    let newAlphaNameString = newSenderName ?? HyberDataInboxSender.unknownSenderNameString
    guard sender?.title != newAlphaNameString else { return }
    sender = HyberDataInboxSender.getHyberDataInboxSender(
        newAlphaNameString,
        inManagedObjectContext: self.managedObjectContext)
  }
  
  /**
   Returns `String` with alpha-name
   - Returns: `String` with alpha-name
   */
  func getSenderNameString() -> String {
    return sender?.title ?? HyberDataInboxSender.unknownSenderNameString
  }
  
}

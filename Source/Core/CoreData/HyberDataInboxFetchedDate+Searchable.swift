//
//  HyberDataInboxFetchedDate+Searchable.swift
//  Hyber
//
//  Created by Vitalii Budnik on 1/26/16.
//
//

import Foundation
import CoreData

extension HyberDataInboxFetchedDate: NSManagedObjectSearchable {
  // swiftlint:disable line_length
  /**
   Search and creates (if needed) `HyberDataInboxFetchedDate` object for passed date
   
   - parameter date: `NSTimeInterval` for date from 00:00:00 UTC on 1 January 2001
   - parameter managedObjectContext: `NSManagedObjectContext` in what to search. (optional. Default value: 
   `HyberCoreDataHelper.managedObjectContext`)
   - parameter createNewIfNotFound: `true`, `false` otherwise
   - returns: `self` if found, or \``createNewIfNotFound: true`\` passed, `nil` otherwise
   */
  internal static func getHyberDataInboxFetchedDate(
    forDate date: NSTimeInterval,
    inManagedObjectContext managedObjectContext: NSManagedObjectContext? = .None,
    createNewIfNotFound createNew: Bool = false)
    -> HyberDataInboxFetchedDate? // swiftlint:disable:this opening_brace
  {
    let moc = managedObjectContext ?? HyberCoreDataHelper.newManagedObjectContext()
    // swiftlint:enable line_length
    guard let registeredUserPhone = Hyber.registeredUserPhone else {
      return .None
    }
    
    let startOfDay = NSDate(timeIntervalSinceReferenceDate: date).startOfDay()
    
    let predicate = NSPredicate(format: "fetchedDate == %@ && to == \(registeredUserPhone)", startOfDay)
    guard let fetchedDate = HyberDataInboxFetchedDate.findObject(
      withPredicate: predicate,
      inManagedObjectContext: moc,
      createNewIfNotFound: createNew) as? HyberDataInboxFetchedDate
      else { // swiftlint:disable:this statement_position
        return .None
    }
    
    if fetchedDate.fetchedDate != startOfDay.timeIntervalSinceReferenceDate {
      fetchedDate.fetchedDate = startOfDay.timeIntervalSinceReferenceDate
    }
    
    let newLastMessageDate: NSTimeInterval
    if fetchedDate.fetchedDate == NSDate().startOfDay().timeIntervalSinceReferenceDate {
      newLastMessageDate = max(startOfDay.timeIntervalSinceReferenceDate, fetchedDate.lastMessageDate)
    } else if fetchedDate.fetchedDate > NSDate().endOfDay().timeIntervalSinceReferenceDate {
      newLastMessageDate = startOfDay.timeIntervalSinceReferenceDate
    } else {
      newLastMessageDate = startOfDay.endOfDay().timeIntervalSinceReferenceDate
    }
    
    if fetchedDate.lastMessageDate != newLastMessageDate {
      fetchedDate.lastMessageDate = newLastMessageDate
    }
    if fetchedDate.to != Int64(registeredUserPhone) {
      fetchedDate.to = Int64(registeredUserPhone)
    }
    if fetchedDate.fetchedDate != startOfDay.timeIntervalSinceReferenceDate {
      fetchedDate.fetchedDate = startOfDay.timeIntervalSinceReferenceDate
    }
    return fetchedDate
    
  }
  
  /**
   Sets `lastMessageDate` if `self` contains todays date
   */
  private func setLastMessageDate() {
    if fetchedDate == NSDate().startOfDay().timeIntervalSinceReferenceDate {
      let newLastMessageDate: NSTimeInterval
      
      var maxDeliveredDate: NSTimeInterval? = .None
      let messagesSet = messages as? Set<HyberDataInboxMessage>
      messagesSet?.forEach() { message in
        if message.type != HyberMessageType.PushNotification.rawValue {
          maxDeliveredDate = max(maxDeliveredDate ?? 0, message.deliveredDate)
        }
      }
      
      if let _lastMessageDate = maxDeliveredDate {
        newLastMessageDate = _lastMessageDate
      } else {
        newLastMessageDate = lastMessageDate
      }
      if lastMessageDate != newLastMessageDate {
        lastMessageDate = newLastMessageDate
      }
    }
  }
  
  internal override func willSave() {
    
    setLastMessageDate()
    
    super.willSave()
  }
  
}

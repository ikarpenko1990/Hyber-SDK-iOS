//
//  HyberDataInboxMessage+CoreDataProperties.swift
//  Hyber
//
//  Created by Vitalii Budnik on 2/25/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension HyberDataInboxMessage {

  /**
   `NSTimeInterval` message delivered date. (from 00:00:00 UTC on 1 January 2001)
   */
  @NSManaged var deliveredDate: NSTimeInterval
  
  /**
   `String` representing message body. Can be `nil`
   */
  @NSManaged var message: String?
  
  /**
   `NSDecimalNumber` Global Message Services message id (`UInt64`)
   */
  @NSManaged var messageID: NSDecimalNumber?
  
  
  /**
   `String` representing message title. Can be `nil`
   */
  @NSManaged var title: String?
  
  /**
   `Int16` message type.
   - SeeAlso: `HyberMessageType` for details
   */
  @NSManaged var type: Int16
  
  /**
   `HyberDataInboxFetchedDate` describing other messages, recieved at delivered date
   */
  @NSManaged var fetchedDate: HyberDataInboxFetchedDate?
  
  /**
   `HyberDataInboxSender` representing senders name
   */
  @NSManaged var sender: HyberDataInboxSender?

  /**
   `Bool` with `true` value, if message marked as deleted, `false` otherwise
   */
  @NSManaged var deletionMark: Bool
  
}

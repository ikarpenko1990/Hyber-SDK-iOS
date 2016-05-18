//
//  HyberDataInboxFetchedDate+CoreDataProperties.swift
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

extension HyberDataInboxFetchedDate {

  /**
   `NSTimeInterval` describing date from 00:00:00 UTC on 1 January 2001
   */
  @NSManaged var fetchedDate: NSTimeInterval
  
  /**
   `Int64` phone number, that recieved messsages
   */
  @NSManaged var lastMessageDate: NSTimeInterval
  
  /**
   `NSTimeInterval` describing date from 00:00:00 UTC on 1 January 2001,
   with the latest message date for todays messages, or end of day for other days
   */
  @NSManaged var to: Int64 // swiftlint:disable:this variable_name
  
  /**
   `NSSet` of `HyberDataInboxMessage`s for this date
   */
  @NSManaged var messages: NSSet?

}

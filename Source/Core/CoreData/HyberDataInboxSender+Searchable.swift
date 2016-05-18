//
//  HyberDataInboxSender+Searchable.swift
//  Hyber
//
//  Created by Vitalii Budnik on 2/25/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation
import CoreData

extension HyberDataInboxSender: NSManagedObjectSearchable {
  
  // swiftlint:disable line_length
  /**
   Search and creates (if needed) `HyberDataInboxFetchedDate` object for passed date
   
   - parameter senderName: `String` with sender name
   - parameter managedObjectContext: `NSManagedObjectContext` in what to search. (optional. Default value:
   `HyberCoreDataHelper.managedObjectContext`)
   - returns: `self` if found, or successfully created, `nil` otherwise
   */
  internal static func getHyberDataInboxSender(
    senderName: String?,
    inManagedObjectContext managedObjectContext: NSManagedObjectContext? = HyberCoreDataHelper.managedObjectContext)
    -> HyberDataInboxSender? // swiftlint:disable:this opnening_brace
  {
    // swiftlint:enable line_length
    
    let senderNameString = senderName ?? unknownSenderNameString
    
    let predicate = NSPredicate(format: "title == %@", senderNameString)
    guard let sender = HyberDataInboxSender.findObject(
      withPredicate: predicate,
      inManagedObjectContext: managedObjectContext) as? HyberDataInboxSender
      else // swiftlint:disable:this opnening_brace
    {
        return .None
    }
    
    sender.title = senderNameString
    
    return sender
  }
  
  /**
   Unlocalized default string for unknown alpha-name in remote push-notification
   */
  internal static var unknownSenderNameString: String {
    return "_UNKNOWN_ALPHA_NAME_"
  }
  
}

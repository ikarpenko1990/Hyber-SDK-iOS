//
//  HyberPushNotification+CoreData.swift
//  Hyber
//
//  Created by Vitalii Budnik on 1/25/16.
//
//

import Foundation
import CoreData
import UIKit

/**
 Saves `self` to CoreData DB
 */
internal extension HyberPushNotification {
  
  /**
   Saves `self` to CoreData DB
   - Returns: `true` if successfully saved, `false` otherwise
   */
  func save() -> HyberDataInboxMessage? {
    
    guard UIApplication.sharedApplication().applicationState != .Inactive
      else { return .None }
    
    let moc = HyberCoreDataHelper.managedObjectContext
    
    guard let
      entity =  NSEntityDescription.entityForName(
        "HyberDataInboxMessage",
        inManagedObjectContext: moc),
      
      coreDataPushNotification = NSManagedObject(
        entity: entity,
        insertIntoManagedObjectContext: moc) as? HyberDataInboxMessage
      
      else {
        return .None
    }
    
    coreDataPushNotification.messageID       = NSDecimalNumber(unsignedLongLong: hyberMessageID)
    coreDataPushNotification.message         = body
    coreDataPushNotification.setSenderNameString(sender)
    coreDataPushNotification.deliveredDate   = deliveredDate.timeIntervalSinceReferenceDate
    coreDataPushNotification.type            = HyberMessageType.PushNotification.rawValue
    
    coreDataPushNotification.setFethcedDate()
    
    let saveResult = HyberCoreDataHelper.managedObjectContext.saveSafeRecursively()
    switch saveResult {
    case .Success:
      return coreDataPushNotification
    default:
      return .None
    }
    
    
    
  }
  
}

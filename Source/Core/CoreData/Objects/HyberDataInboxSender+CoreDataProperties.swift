//
//  HyberDataInboxSender+CoreDataProperties.swift
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

extension HyberDataInboxSender {
  /**
   Name
   */
  @NSManaged var title: String
  
  /**
   Messages with this alpha-name
   */
  @NSManaged var messages: NSSet?

}

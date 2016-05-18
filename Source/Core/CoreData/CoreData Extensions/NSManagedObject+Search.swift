//
//  NSManagedObject+Search.swift
//  Hyber
//
//  Created by Vitalii Budnik on 1/25/16.
//
//

import Foundation
import CoreData

/**
 Instances of conforming types provide a `findObject` function
 */
internal protocol NSManagedObjectSearchable: class {
  /**
   Searches for an object in order, that satisfy the `withPredicate` parameter
   
   - parameter predicate: `NSPredicate` object that defines logical conditions to searching object
   - parameter managedObjectContext: `NSManagedObjectContext` where to search for an object. (optional)
   - parameter createNew: pass `true` to create new object, if existing is not found. `false` otherwise
   - returns: `NSManagedObject` if found, or successflly created, otherwise returns `nil`
   */
  static func findObject(
    withPredicate predicate: NSPredicate,
    inManagedObjectContext managedObjectContext: NSManagedObjectContext?,
    createNewIfNotFound createNew: Bool) -> NSManagedObject?
  
}

/// Stores entity names for class names of `NSManagedObject`s
private var entityNames: [String : String] = [:]

internal extension NSManagedObjectSearchable where Self: NSManagedObject {
  
  /// The name of a class as a string
  private static var className: String { return NSStringFromClass(Self) }
  
  /// The name of an entity as a string if entity is found for `self` class name, otherwise `nil`
  private static var entityName: String? {
    var entityName: String? = .None
    //let delegate = appDelegate()//UIApplication.sharedApplication().delegate as! AppDelegate
    if let entityName = entityNames[className] {
      return entityName
    } else {
      let className = Self.className
      let managedObjectModel = HyberCoreDataHelper.managedObjectModel
      for entityDescription in managedObjectModel.entities {
        if entityDescription.managedObjectClassName == className {
          entityName = entityDescription.name
          break
        }
      }
      entityNames[className] = entityName
      return entityName
    }
  }
  
  /**
   Searches for an object in order, that satisfy the `withPredicate` parameter
   
   - parameter predicate: `NSPredicate` object that defines logical conditions to searching object
   - parameter managedObjectContext: `NSManagedObjectContext` where to search for an object. 
   (optional. Creates new context if `nil` is passed)
   - parameter createNew: pass `true` to create new object, if existing is not found. `false` otherwise. 
   Default value: `true`
   - returns: `NSManagedObject` if found, or successflly created, otherwise returns `nil`
   */
  static func findObject(
    withPredicate predicate: NSPredicate,
    inManagedObjectContext managedObjectContext: NSManagedObjectContext? = .None,
    createNewIfNotFound createNew: Bool = true)
    -> NSManagedObject? // swiftlint:disable:this opening_brace
  {
    
    let moc = managedObjectContext ?? HyberCoreDataHelper.newManagedObjectContext()
    
    guard let entityName = entityName else { return .None }
    
    let fetchRequest = NSFetchRequest(entityName: entityName)
    fetchRequest.fetchBatchSize = 1
    fetchRequest.fetchLimit = 1
    fetchRequest.predicate = predicate
    
    do {
      
      guard let result = try moc.executeFetchRequest(fetchRequest) as? [NSManagedObject] else {
        return .None
      }
      
      guard result.isEmpty else { return result.first }
      
      guard createNew else { return .None }
      
      guard let entity =  NSEntityDescription.entityForName(entityName,
        inManagedObjectContext: moc) else { return .None }
      
      let newManagedObject = NSManagedObject(entity: entity, insertIntoManagedObjectContext: moc)
      
      return newManagedObject
      
    } catch {
      hyberLog.error("\(error)")
      return .None
    }
    
  }
  
}

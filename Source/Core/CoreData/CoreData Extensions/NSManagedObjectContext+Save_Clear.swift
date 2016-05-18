//
//  NSManagedObjectContext+Save_Clear.swift
//  Hyber
//
//  Created by Vitalii Budnik on 1/26/16.
//
//

import CoreData

/**
 Provides deletion of entities methods
 */
internal extension NSManagedObjectContext {
  
  /**
   Erases all stored data
   - Returns: `SaveResult`
   */
  func deleteObjectctsOfAllEntities() -> HyberResult<Void> {
    
    return deleteObjectctsOfEntities(persistentStoreCoordinator?.managedObjectModel.entities)
    
  }
  
  /**
  Erases all stored data in passed `NSEntityDescription`s
   - Parameter entities: `NSEntityDescription` array, that must to be erazed
  - Returns: `SaveResult`
  */
  func deleteObjectctsOfEntities(entities: [NSEntityDescription]?) -> HyberResult<Void> {
    
    guard let entities = entities else { return .Success() }
    
    var result: HyberResult<Void>? = .None
    
    for entity in entities {
      if let entityName = entity.name where !entity.abstract {
        
        let entityDeleteResult = deleteObjectctsOfEntity(entityName, save: false)
        
        if let _ = entityDeleteResult.value {
          result = entityDeleteResult
          break
        }
      }
    }
    
    return result ?? .Success()
    
  }
  
  /**
   Gets all stored data in entity with name
   
   - parameter entityName: The entity name to be fetched
   
   - throws: `NSError` 
   
   - returns: Array on `NSManagedObject`
   */
  func getObjectctsOfEntity(entityName: String) throws -> [NSManagedObject]? {
    
    let fetchRequest = NSFetchRequest(entityName: entityName)
    fetchRequest.includesPropertyValues = false
    
    return try executeFetchRequest(fetchRequest) as? [NSManagedObject]
    
  }
  
  /**
   Erases all stored data in entity with name
   - Parameter entityName: The entity name to be erased
   - Parameter save: `Bool` flag that tells to save context after deleting all objects or not. 
   Default value - `true`
   - Returns: `SaveResult`
   */
  func deleteObjectctsOfEntity(entityName: String, save: Bool = true) -> HyberResult<Void> {
    
    let results: [NSManagedObject]?
    do {
      results = try getObjectctsOfEntity(entityName)
    } catch {
      hyberLog.error("executeFetchRequest error: \(error)")
      return .Failure(.CoreDataError(.FetchError(error as NSError)))
    }
    
    guard let fetchedObjects = results else {
      return .Failure(.CoreDataError(.FetchError(NSError(
        domain: "com.gms-worldwide.Hyber",
        code: 1,
        userInfo: ["description": "Could not cast Fetch Request result to [NSManagedObject]"]))))
    }
    
    for object in fetchedObjects {
      deleteObject(object)
    }
    
    if save {
      return saveSafeRecursively()
    }
    
    return .Success()
    
  }
  
}

/**
 Provides `saveRecursively` and `saveSafeRecursively() -> SaveResult` methods
 */
internal extension NSManagedObjectContext {
  
  /**
   Saves `self` recursively and waits for response (uses all `parentContext`s)
   - Throws: `NSError`
   */
  func saveRecursively() throws {
    
    guard hasChanges else { return }
    
    var saveError: ErrorType? = .None
    
    performBlockAndWait() {
      do {
        try self.save()
      } catch {
        saveError = error
        hyberLog.error("NSManagedObjectContext couldn't be saved \(error) ")
      }
    }
    if let saveError = saveError {
      throw saveError
    }
    
    try parentContext?.saveRecursively()
    
  }
  
  /**
   Saves `self` recursively and waits for response (uses all `parentContext`s). No `throw`s
   - Returns: `SaveResult`
   */
  func saveSafeRecursively() -> HyberResult<Void> {
    
    guard hasChanges else { return .Success() }
    
    var result: HyberResult<Void> = .Success()
    performBlockAndWait() {
      do {
        try self.save()
        result = .Success()
      } catch {
        print("NSManagedObjectContext couldn't be saved \(error) context: \(self)")
        result = .Failure(.CoreDataError(HyberError.CoreData.SaveError(error as NSError)))
      }
    }
    
    guard let _ = result.value else { return result }
    
    return parentContext?.saveSafeRecursively() ?? .Success()
    
  }
  
}

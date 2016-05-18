//
//  SerialOperationQueue.swift
//  Hyber
//
//  Created by Vitalii Budnik on 5/18/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation

/// Serial operation queue
final class SerialOperationQueue: NSOperationQueue {
  
  /// Shared instance of Serial operation queue
  static let sharedInstance = SerialOperationQueue()
  
  override init() {
    super.init()
    maxConcurrentOperationCount = 1
    qualityOfService = .UserInitiated
  }
  
  /**
   Wraps the specified block in an operation object and adds it to the reciever.
   
   Once added, the specified `block` remains in the queue until wrapped `NSBlockOperation` method 
   `isFinished` returns `true`.
   
   - parameter block: The block to execute from the operation object.
   The block should take no parameters and have no return value.
   
   - parameter wait: If `true`, the current thread is blocked until all of
   the specified operations finish executing. If `false`, the operations are added
   to the queue and control returns immediately to the caller.
   
   - parameter completionBlock: closure to run, when operation finished
   
   - returns: new `NSBlockOperation`
   */
  func addOperationWithBlock(
    block: () -> Void,
    waitUntilFinished wait: Bool,
    completionBlock: (() -> Void)? = .None)
    -> NSBlockOperation //swiftlint:disable:this opening_brace
  {
    let blockOperation = NSBlockOperation(block: block)
    if let completionBlock = completionBlock {
      blockOperation.completionBlock = completionBlock
    }
    addOperations([blockOperation], waitUntilFinished: wait)
    return blockOperation
  }
  
}

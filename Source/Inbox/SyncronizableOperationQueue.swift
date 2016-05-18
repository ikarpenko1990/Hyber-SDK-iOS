//
//  SyncronizableOperationQueue.swift
//  Hyber
//
//  Created by Vitalii Budnik on 5/18/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation

protocol SyncronizableOperationQueue {
  var serialOperationQueue: SerialOperationQueue { get }
}
// swiftlint:disable opening_brace
extension SyncronizableOperationQueue {
  
  func synchronized(block: () -> Void) {
    serialOperationQueue.addOperationWithBlock(block)
  }
  
  func synchronized(
    block: () -> Void,
    completionBlock: (() -> Void)? = .None)
    -> NSBlockOperation
  {
    let blockOperation = NSBlockOperation(block: block)
    if let completionBlock = completionBlock {
      blockOperation.completionBlock = completionBlock
    }
    return serialOperationQueue.addOperationWithBlock(
      block,
      waitUntilFinished: false,
      completionBlock: completionBlock)
  }
  
  func synchronized_wait(block: () -> Void) -> NSBlockOperation {
    return serialOperationQueue.addOperationWithBlock(block, waitUntilFinished: true)
  }
  
  func synchronized_wait(
    block: () -> Void,
    completionBlock: (() -> Void)? = .None)
    -> NSBlockOperation
  {
    return serialOperationQueue.addOperationWithBlock(
      block,
      waitUntilFinished: true,
      completionBlock: completionBlock)
  }
  
} // swiftlint:enable opening_brace

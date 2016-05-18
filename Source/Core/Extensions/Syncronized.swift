//
//  Syncronized.swift
//  Hyber
//
//  Created by Vitalii Budnik on 3/4/16.
//
//

import Foundation

///
private let serialLockQueue = dispatch_queue_create(
  "com.gms-worldwide.Hyber.LockQueue",
  DISPATCH_QUEUE_SERIAL)
/**
 Runs synchronized `closure` on 'lockObject'
 - Parameter lockQueue: Serial lock queue
 - Parameter wait: `Bool` flag. `true` to make a sync call, `false` - async
 - Parameter closure: The closure to be executed in syncronized mode
 */
internal func synchronized(lockQueue: dispatch_queue_t?, wait: Bool = true, closure: () -> Void) {
  
  if wait {
    
    dispatch_sync(lockQueue ?? serialLockQueue) {
      closure()
    }
    
  } else {
    
    dispatch_async(lockQueue ?? serialLockQueue) {
      closure()
    }
    
  }
  
}

/**
 Returns result of `closure` synchronized with 'lockObject'
 - Parameter lockQueue: Serial lock queue
 - Parameter closure: The closure to be executed in syncronized mode
 - Returns: result of executed closure
 */
@warn_unused_result internal func synchronized<T>(lockQueue: dispatch_queue_t?, closure: () -> T) -> T {
  
  var closureResult: T? = .None
//  let waitBlock = {
    dispatch_sync(lockQueue ?? serialLockQueue) {
      closureResult = closure()
    }
//  }
  
//  dispatch_block_wait(waitBlock, DISPATCH_TIME_FOREVER)
  
  guard let result = closureResult else {
    fatalError()
  }
  return result
}

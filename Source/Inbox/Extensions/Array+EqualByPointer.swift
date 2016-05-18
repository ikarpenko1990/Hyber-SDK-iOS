//
//  Array+EqualByPointer.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/22/16.
//
//

import Foundation

extension Array {
  
  func samePointerAs(anotherArray: Array<Element>) -> Bool {
    
    return withUnsafeBufferPointer { (selfPointer) -> Bool in
      anotherArray.withUnsafeBufferPointer { (anotherPointer) -> Bool in
        let result = selfPointer.baseAddress == anotherPointer.baseAddress
        return result
      }
    }
    
  }
}

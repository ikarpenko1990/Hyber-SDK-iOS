//
//  HyberInboxViewControllerMessageFetcherResult.swift
//  Hyber
//
//  Created by Vitalii Budnik on 5/18/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation

struct HyberInboxViewControllerMessageFetcherResult { //swiftlint:disable:this type_name
  
  static let empty = HyberInboxViewControllerMessageFetcherResult(delete: [], add: [], reload: [])
  
  let delete: [NSIndexPath],
  add: [NSIndexPath],
  reload: [NSIndexPath]
  
}

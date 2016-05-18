//
//  String+AttributedString.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/22/16.
//
//

import Foundation

internal extension String {
  
  internal func attributedString(textAttributes: [String: AnyObject]) -> NSAttributedString {
    return NSAttributedString(
      string: self,
      attributes: textAttributes)
  }
  
}

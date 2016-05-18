//
//  UIColor+DarkerLighter.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/18/16.
//
//

import Foundation
import UIKit

internal extension UIColor {
  
  func darker(on: CGFloat = 0.1) -> UIColor { // swiftlint:disable:this variable_name
    
    return gradient(-fabs(on))
    
  }
  
  private func gradient(shift: CGFloat) -> UIColor {
    
    var red: CGFloat = 0,
    green: CGFloat = 0,
    blue: CGFloat = 0,
    alpha: CGFloat = 0
    
    if getRed(&red,
              green: &green,
              blue: &blue,
              alpha: &alpha) // swiftlint:disable:this opening_brace
    {
      return UIColor(red: min(max(red + shift, 0.0), 1.0),
                     green: min(max(green + shift, 0.0), 1.0),
                     blue: min(max(blue + shift, 0.0), 1.0),
                     alpha: alpha)
    }
    
    return self
    
  }
  
  func lighter(on: CGFloat = 0.1) -> UIColor { // swiftlint:disable:this variable_name
    
    return gradient(fabs(on))
    
  }
  
}

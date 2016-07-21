//
//  UIImage+Images.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/20/16.
//
//

import Foundation
import UIKit

extension UIImage {
  
  /// Filter image
  static var filter: UIImage? {
    return UIImage(
      named: "Filter",
      inBundle: Hyber.nonLocalizedBundle,
      compatibleWithTraitCollection: .None)
  }
  
  /// Share image
  static var share: UIImage? {
    return UIImage(
      named: "Share",
      inBundle: Hyber.nonLocalizedBundle,
      compatibleWithTraitCollection: .None)
  }
  
}


extension UIImage {
  
  /**
   Return rounded image
   
   - returns: rounded image
   */
  func roundedImage() -> UIImage {
    let imageLayer = CALayer()
    imageLayer.frame = CGRect(origin: CGPoint.zero, size: size)
    imageLayer.masksToBounds = true
    imageLayer.cornerRadius = fmin(size.width, size.height) / 2.0
    imageLayer.contents = CGImage
    UIGraphicsBeginImageContextWithOptions(size, false, 1)
    imageLayer.renderInContext(UIGraphicsGetCurrentContext()!)
    
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
  }
  
}

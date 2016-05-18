//
//  UIScrollView+ContentOffsetPosition.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/19/16.
//
//

import Foundation
import UIKit

extension UIScrollView {
  
  var topContentOffsetPosition: CGFloat {
    return contentOffset.y + contentInset.top
  }
  
  var contentOffsetIsAtTopPosition: Bool {
    return topContentOffsetPosition <= 0
  }
  
  var contentOffsetIsAtBottomPosition: Bool {
    let contenHeight = contentSize.height
    var bottomOffset = contenHeight - bounds.size.height + contentInset.bottom
    if bottomOffset + contenHeight <= 0 {
      bottomOffset = -contentInset.top
    }
    return bottomOffset - contentOffset.y <= 0
  }
  
}

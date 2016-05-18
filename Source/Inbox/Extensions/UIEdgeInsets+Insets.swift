//
//  UIEdgeInsets+Insets.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/22/16.
//
//

import Foundation
import UIKit

internal extension UIEdgeInsets {
  internal var horizontalInset: CGFloat {
    return left + right
  }
  internal var verticalInset: CGFloat {
    return top + bottom
  }
}

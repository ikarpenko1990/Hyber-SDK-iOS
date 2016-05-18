//
//  CGSize+max.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/22/16.
//
//

import Foundation
import CoreGraphics

internal extension CGSize {
  internal static var max: CGSize = {
    return CGSize(width: CGFloat.max, height: CGFloat.max)
  }()
}

//
//  LinesAndPoints.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/20/16.
//
//

import Foundation
import QuartzCore
import UIKit

/**
 Path
 
 - MoveToPoint: Move to point. Contains `CGPoint`
 
 - CurveToPoint: Draw curve to point. Contains `CGPoint` and two control `CGPoint`s
 
 - QuadCurveToPoint: Draw quadcurve to point. Contains `CGPoint` and control `CGPoint`
 
 - LineToPoint: Draw line to point. Contains `CGPoint`
 
 - Close: Close path
 
 - Fill: Fill path
 
 */
internal enum LinesAndPonts {
  
  case MoveToPoint(CGPoint)
  case CurveToPoint(CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint)
  case QuadCurveToPoint(CGPoint, controlPoint: CGPoint)
  case LineToPoint(CGPoint)
  case Close
  case Fill
  
  /**
   Draws path to `self`
   
   - parameter path: The mutable path to change. The path must not be empty.
   - parameter context: A graphics context
   */
  func draw(path: CGMutablePath, inContext context: CGContext) {
    
    switch self {
      
    case .Close:
      CGContextBeginPath(context)
      CGContextAddPath(context, path)
      break
      
    case .Fill:
      CGContextFillPath(context)
      break
      
    case .MoveToPoint(let point):
      CGPathMoveToPoint(
        path,
        nil,
        point.x, point.y)
      break
      
    case .QuadCurveToPoint(let point, let controlPoint):
      CGPathAddQuadCurveToPoint(
        path,
        nil,
        controlPoint.x, controlPoint.y,
        point.x, point.y)
      break
      
    case .LineToPoint(let point):
      CGPathAddLineToPoint(
        path,
        nil,
        point.x, point.y)
      break
      
    case .CurveToPoint(let point, let controlPoint1, let controlPoint2):
      CGPathAddCurveToPoint(
        path,
        nil,
        controlPoint1.x, controlPoint1.y,
        controlPoint2.x, controlPoint2.y,
        point.x, point.y)
      break
    
    }
    
  }
}

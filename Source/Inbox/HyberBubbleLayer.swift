//
//  HyberBubbleLayer.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/15/16.
//
//

import Foundation
import QuartzCore
import UIKit

internal class HyberBubbleLayer: CAShapeLayer {
  
  override var fillColor: CGColor? {
    didSet {
      setNeedsDisplay()
    }
  }
  
  override var cornerRadius: CGFloat {
    didSet {
      setNeedsDisplay()
    }
  }
  
  override init(layer: AnyObject) {
    super.init(layer: layer)
    initialSetup()
  }
  
  override init() {
    super.init()
    initialSetup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialSetup()
  }
  
  /**
   Initial setup
    */
  private func initialSetup() {
    backgroundColor = UIColor.clearColor().CGColor
    needsDisplayOnBoundsChange = true
  }
  
  /**
   Returns `Array` of `LinesAndPonts` containing path to draw
   
   - parameter size: `CGSize` of bubble
   
   - returns: `Array` of `LinesAndPonts` containing path to draw
   */ //swiftlint:disable function_body_length
  func generateBubblePathOfSize(size: CGSize) -> [LinesAndPonts] {
    var point: CGPoint
    var controlPoint: CGPoint
    var previousPoint: CGPoint
    
    point = CGPoint(x: cornerRadius * 1.5, y: 0)
    previousPoint = point
    var path = [LinesAndPonts]()
    
    path.append(.MoveToPoint(point))
    
    point = CGPoint(x: size.width - cornerRadius, y: previousPoint.y)
    path.append(.LineToPoint(point))
    previousPoint = point
   
    point = CGPoint(x: size.width, y: cornerRadius)
    controlPoint = CGPoint(x: point.x, y: previousPoint.y)
    path.append(.QuadCurveToPoint(point, controlPoint: controlPoint))
    previousPoint = point
    
    point = CGPoint(x: previousPoint.x, y: size.height - cornerRadius)
    path.append(.LineToPoint(point))
    previousPoint = point
    
    point = CGPoint(x: size.width - cornerRadius, y: size.height)
    controlPoint = CGPoint(x: previousPoint.x, y: point.y)
    path.append(.QuadCurveToPoint(point, controlPoint: controlPoint))
    previousPoint = point
   
    point = CGPoint(x: cornerRadius * 3.5, y: previousPoint.y)
    path.append(.LineToPoint(point))
    previousPoint = point
    
    point = CGPoint(x: previousPoint.x - cornerRadius * 2.5, y: size.height - cornerRadius * 0.5)
    controlPoint = CGPoint(x: point.x, y: previousPoint.y)
    path.append(.QuadCurveToPoint(point, controlPoint: controlPoint))
    previousPoint = point
    
    point = CGPoint(x: 0, y: size.height)
    controlPoint = CGPoint(x: previousPoint.x, y: point.y)
    path.append(.QuadCurveToPoint(point, controlPoint: controlPoint))
    previousPoint = point
    
    point = CGPoint(x: cornerRadius * 0.4, y: size.height - cornerRadius * 0.5)
    controlPoint = CGPoint(x: point.x, y: size.height - cornerRadius * 0.35)
    path.append(.QuadCurveToPoint(point, controlPoint: controlPoint))
    previousPoint = point
    
    point = CGPoint(x: previousPoint.x, y: cornerRadius)
    path.append(.LineToPoint(point))
    previousPoint = point
    
    point = CGPoint(x: cornerRadius * 1.5, y: 0)
    controlPoint = CGPoint(x: previousPoint.x, y: point.y)
    path.append(.QuadCurveToPoint(point, controlPoint: controlPoint))
    
    path.append(.Close)
    path.append(.Fill)
    
    return path
    
  } //swiftlint:enable function_body_length
  
  override func drawInContext(ctx: CGContext) {
    super.drawInContext(ctx)
    drawBubble(ctx)
  }
  
  /**
   Draws bubble
   
   - parameter ctx: The graphics context in which to draw the bubble
   */
  func drawBubble(ctx: CGContext) {
    
    let path = generateBubblePathOfSize(CGContextGetClipBoundingBox(ctx).size)
    
    let thePath = CGPathCreateMutable()
    
    CGContextSetFillColorWithColor(ctx, fillColor)
    
    path.forEach { $0.draw(thePath, inContext: ctx) }
    
  }
  
}

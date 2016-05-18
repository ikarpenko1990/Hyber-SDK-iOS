//
//  HyberInboxController+PanGestureRecognizer.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/19/16.
//
//

import Foundation
import UIKit

// MARK: - PanGestureRecognizer
internal extension HyberInboxController {
  
  func updateTableViewCellFrames() {
    
    let visibleInboxCells = self.visibleInboxCells
    guard !visibleInboxCells.isEmpty else { return }
    
    let horizontalScrollingOffset = self.horizontalScrollingOffset
    let horizontalScrolling = self.horizontalScrolling
    
    visibleInboxCells.forEach { inboxCell in
      inboxCell.setTimeLabelOffset(
        horizontalScrollingOffset,
        animated: !horizontalScrolling)
    }
  }
  
  @objc func horizontalPanGestureDetected(gestureRecognizer: UIPanGestureRecognizer) {
    if gestureRecognizer.state == .Changed {
      
      let xOffset: CGFloat = gestureRecognizer.translationInView(self.tableView).x
      
      if xOffset > 0 {
        horizontalScrollingOffset = 0
      } else {
        horizontalScrollingOffset = xOffset
      }
      
    }
    
    if gestureRecognizer.state == .Failed
      || gestureRecognizer.state == .Ended
      || gestureRecognizer.state == .Cancelled //swiftlint:disable:this opening_brace
    {
      gestureRecognizer.enabled = !tableView.editing
      horizontalScrolling = false
    }
  }
  
  func configureHorizontalPanGesture() {
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(horizontalPanGestureDetected(_:)))
    panGesture.delegate = self
    panGesture.cancelsTouchesInView = false
    panGesture.enabled = !tableView.editing
    horizontalPanGestureRecognizer = panGesture
    tableView.addGestureRecognizer(panGesture)
  }
  
}

// MARK: - UIGestureRecognizerDelegate
extension HyberInboxController: UIGestureRecognizerDelegate {
  
  /**
   Returns `true` for all passed UIGestureRecognizer except `self.horizontalPanGestureRecognizer`.
   If passed recognizer is `self.horizontalPanGestureRecognizer` returns `true` if `tableView` is
   not editing
   
   - parameter gestureRecognizer: An instance of a subclass of the abstract base class `UIGestureRecognizer`.
   This gesture-recognizer object is about to begin processing touches to determine 
   if its gesture is occurring.
   
   - returns: `true` if `gestureRecognizer` is not `horizontalPanGestureRecognizer`. Otherwise:
   returns `true` if `tableView` not `editing`
   */
  public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    
    guard let horizontalPanGestureRecognizer = horizontalPanGestureRecognizer
      where gestureRecognizer == horizontalPanGestureRecognizer
      else {
      return true
    }
    
//    let translation = horizontalPanGestureRecognizer.translationInView(self.tableView)
    
    let horizontalScrolling = !tableView.editing
    
    
    self.horizontalScrolling = horizontalScrolling
    
    return horizontalScrolling
    
  }
  
  @available(iOS 9.0, *)
  public func gestureRecognizer( //swiftlint:disable:this missing_docs
    gestureRecognizer: UIGestureRecognizer,
    shouldReceivePress press: UIPress)
    -> Bool //swiftlint:disable:this opening_brace
  {
    return true
  }
  
  public func gestureRecognizer( //swiftlint:disable:this missing_docs
    gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer)
    -> Bool //swiftlint:disable:this opening_brace
  {
    guard let horizontalPanGestureRecognizer = horizontalPanGestureRecognizer
      where gestureRecognizer == horizontalPanGestureRecognizer
      else {
      return true
    }
    
    return true
  }
  
  public func gestureRecognizer( //swiftlint:disable:this missing_docs
    gestureRecognizer: UIGestureRecognizer,
    shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer)
    -> Bool //swiftlint:disable:this opening_brace
  {
    return false
  }
  
  public func gestureRecognizer( //swiftlint:disable:this missing_docs
    gestureRecognizer: UIGestureRecognizer,
    shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer)
    -> Bool //swiftlint:disable:this opening_brace
  {
    return false
  }
}

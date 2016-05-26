//
//  HyberInboxController.swift
//  Hyber
//
//  Created by Vitalii Budnik on 3/30/16.
//
//

import Foundation
import UIKit

/// Hyber Inbox Controller
public class HyberInboxController: UITableViewController {
  
  /// Message fetcher
  internal let fetcher: HyberInboxViewControllerMessageFetcher =
    HyberInboxViewControllerMessageFetcher.sharedInstance
  
  /// Auto-fetch delivered messages timer
  internal weak var todaysMesagesUpdateTimer: NSTimer? = .None
  
  /// `Bool` that indicates is `self` visible
  private (set) var isVisible: Bool = false
  
  /**
   The number of seconds between firings of the todays messages fetcher timer. If it is
   less than or equal to 30.0, sets the value of 30.0 seconds instead. 
   
   - note: `public`
   */
  var todaysMesagesUpdateInterval: NSTimeInterval {
    get {
      return _todaysMesagesUpdateInterval
    }
    set {
      _todaysMesagesUpdateInterval = max(30.0, newValue)
    }
  }
  
  /**
    The number of seconds between firings of the todays messages fetcher timer. If it is
   less than or equal to 30.0, sets the value of 30.0 seconds instead. 
   
   - note: `private`
   */
  private var _todaysMesagesUpdateInterval: NSTimeInterval = 60
  
  //swiftlint:disable cyclomatic_complexity
  internal func updateTableView( //swiftlint:disable:this function_body_length
    data: HyberInboxViewControllerMessageFetcherResult,
    fetchingMessages: Bool,
    scrollToBottom: Bool = false,
    scrollToLastPosition: Bool = false,
    animated: Bool = false,
    completionHandler: (() -> Void)? = .None) //swiftlint:disable:this opening_brace
  {
    let startUpdates: Bool =
      !data.delete.isEmpty
        || !data.add.isEmpty
        || !data.reload.isEmpty
        || fetchingMessages != self.fetchingMessages

    var delete: [NSIndexPath]
    var add: [NSIndexPath]
    let reload: [NSIndexPath]
    if !startUpdates {
      completionHandler?()
      return
    }
    
    if self.fetchingMessages {
      delete = data.delete.map { NSIndexPath(forRow: $0.row + 1, inSection: $0.section) }
      add = data.add.map { NSIndexPath(forRow: $0.row + 1, inSection: $0.section) }
      reload = data.reload.map { NSIndexPath(forRow: $0.row + 1, inSection: $0.section) }
    } else {
      delete = data.delete
      add = data.add
      reload = data.reload
    }
    if fetchingMessages != self.fetchingMessages && fetchingMessages {
      add.append(NSIndexPath(forRow: 0, inSection: 0))
    }
    
    let beforeContentSize: CGSize = tableView.contentSize
    
    let animationDuration: NSTimeInterval

    let deleteRowAnimation: UITableViewRowAnimation
    let reloadRowAnimation: UITableViewRowAnimation
    let addRowAnimation: UITableViewRowAnimation

    if animated && !scrollToLastPosition {
      animationDuration = 0.3

      deleteRowAnimation = .Top
      reloadRowAnimation = .Automatic
      addRowAnimation = .Bottom
      
    } else {
      animationDuration = 0.0
      
      deleteRowAnimation = .None
      reloadRowAnimation = .None
      addRowAnimation = .None
    }
    
    
    if animationDuration > 0.0 {
      
    }

    UIView.setAnimationsEnabled(animated)
    
    self.cellData = fetcher.cellData
    
    let animated: Bool = animated && !scrollToLastPosition
    if !delete.isEmpty || !reload.isEmpty || !add.isEmpty {
      self.tableView.beginUpdates()
      //    }
      
      if !reload.isEmpty {
        self.tableView.reloadRowsAtIndexPaths(reload, withRowAnimation: reloadRowAnimation)
      }
      if !delete.isEmpty {
        self.tableView.deleteRowsAtIndexPaths(delete, withRowAnimation: deleteRowAnimation)
      }
      if !add.isEmpty {
        self.tableView.insertRowsAtIndexPaths(add, withRowAnimation: addRowAnimation)
      }
      
      if fetchingMessages != self.fetchingMessages && fetchingMessages {
        self.fetchingMessages = fetchingMessages
      }
      self.tableView.endUpdates()
    }
    
    UIView.animateWithDuration(
      animationDuration,
      animations: {
        
        let animated = animated && !scrollToLastPosition
        
        if fetchingMessages != self.fetchingMessages && !fetchingMessages {
          self.tableView.beginUpdates()
          self.fetchingMessages = fetchingMessages
          self.tableView.deleteRowsAtIndexPaths(
            .init(count: 1, repeatedValue: NSIndexPath(forRow: 0, inSection: 0)),
            withRowAnimation: deleteRowAnimation)
          self.tableView.endUpdates()
        }
        
        let rowsInSection = self.tableView.numberOfRowsInSection(0)
        if scrollToBottom && rowsInSection > 0 {
          self.tableView.scrollToRowAtIndexPath(
            NSIndexPath(forRow: rowsInSection - 1, inSection: 0),
            atScrollPosition: UITableViewScrollPosition.Top,
            animated: animated)
        }
        
        
      },
      completion: { finished in
        
        UIView.animateWithDuration(
          animationDuration,
          animations: {
            if scrollToLastPosition && !scrollToBottom {
              let afterContentOffset: CGPoint = self.tableView.contentOffset
              let afterContentSize: CGSize = self.tableView.contentSize
              let newContentOffset: CGPoint = CGPoint(
                x: afterContentOffset.x,
                y: max(afterContentOffset.y, -64.0) + afterContentSize.height - beforeContentSize.height)
              self.tableView.setContentOffset(newContentOffset, animated: false)
            }
          },
          completion: { finished in
            
            completionHandler?()
            
        })
        
    })
  }
  
  /**
   The table cells that are visible in the table view. (read-only)
   
   The value of this property is an array containing `UITableViewCell` objects,
   each representing a visible cell in the table view.
   */
  var visibleCells: [UITableViewCell] {
    let visibleCells: [UITableViewCell]
    
    if #available(iOS 9.0, *) {
      visibleCells = tableView.visibleCells
    } else {
      if let visibleIndexPaths = tableView.indexPathsForVisibleRows {
        visibleCells = visibleIndexPaths.flatMap { tableView.cellForRowAtIndexPath($0) }
      } else {
        visibleCells = []
      }
    }
    return visibleCells
  }
  
  /**
   The table `InboxCell`s that are visible in the table view. (read-only)
   
   The value of this property is an array containing `InboxCell` objects,
   each representing a visible cell in the table view.
   */
  var visibleInboxCells: [HyberInboxControllerMessageCell] {
    return visibleCells.flatMap {$0 as? HyberInboxControllerMessageCell}
  }
  
  /**
   The table `HedaderTableViewCell`s that are visible in the table view. (read-only)
   
   The value of this property is an array containing `HedaderTableViewCell` objects,
   each representing a visible cell in the table view.
   */
  var visibleHeaderCells: [HyberInboxControllerHeaderCell] {
    return visibleCells.flatMap {$0 as? HyberInboxControllerHeaderCell }
  }
  
  
  /// Horizontal pan gesture
  internal var horizontalPanGestureRecognizer: UIPanGestureRecognizer? = .None
  /// `Bool` flag indicating is horizontal scrolling activated (`true`) or not (`fals`)
  internal var horizontalScrolling: Bool = false {
    didSet {
      if !horizontalScrolling {
        horizontalScrollingOffset = 0.0
      }
    }
  }
  
  /// Horizontal pan gesture recognizer offset
  internal var horizontalScrollingOffset: CGFloat = 0.0 {
    didSet {
      if oldValue != horizontalScrollingOffset {
        updateTableViewCellFrames()
      }
    }
  }
  
  /// Search controller
  private (set) var searchController: UISearchController = UISearchController(searchResultsController: .None)
  
  /// `Bool` indicating that `tableView` is trying to scroll to bottom
  private var scrollingToBottom = false
  
  /// Selected `HyberMessageType` in search bar scope
  var selectedMessageType: HyberMessageType? = .None
  
  /// `Array<HyberMessageType>` of selected message types
  var selectedMessagesTypes = HyberMessageType.allItems {
    didSet {
      configureSearchBarScopeButtons()
      updateFilter()
    }
  }
  
  internal var hyberLocalizationDidChangeObserver: NSObjectProtocol? = .None
  
  deinit {
    if let hyberLocalizationDidChangeObserver = hyberLocalizationDidChangeObserver {
      NSNotificationCenter.defaultCenter().removeObserver(hyberLocalizationDidChangeObserver)
      self.hyberLocalizationDidChangeObserver = .None
    }
  }
  
  var _fetchingMessages: Bool = false //swiftlint:disable:this variable_name
  var fetchingMessages: Bool {
    get {
      return _fetchingMessages
    }
    set {
      guard _fetchingMessages != newValue else {
        return
      }
      _fetchingMessages = newValue
    }
  }
  
  private (set) var cellData: [HyberInboxCellData] = []
  
}

// MARK: - Lifecycle
extension HyberInboxController {
  
  public override func viewDidLoad() {
    
    fetchTodaysMesages() { [weak self] in
      guard let sSelf = self else { return }
      sSelf.loadPreviousMessages(true)
    }
    
    super.viewDidLoad()
    
    configure()
    
  }
  
  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    isVisible = true
  }
  
  public override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    setTabBarHidden(false, animated: true)
    isVisible = false
  }
  
}

// MARK: - Scrolling
public extension HyberInboxController {
  
  public override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard !decelerate else { return }
    scrollViewDidEndScroll(scrollView)
  }
  
  public override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    scrollViewDidEndScroll(scrollView)
  }
  
  /**
   Scrolling of the content view ended
   
   - parameter scrollView: The scroll-view object that ended the scrolling of the content view.
   */
  func scrollViewDidEndScroll(scrollView: UIScrollView) {
    
    guard self.isVisible else { return }
    
    if !searchController.active
      && tableView.topContentOffsetPosition <= 0.0
      && !tableView.editing && fetcher.hasMorePrevious
      && !fetcher.fetchingPreviousMessages
      && !fetchingMessages //swiftlint:disable:this opening_brace
    {
      loadPreviousMessages()
    }
    
  }
  
}

// MARK: InboxViewControllerTableViewDelegate
extension HyberInboxController: HyberInboxControllerMessageCellDelegate {
  
  func inboxCellWillEnterEditingMode(cell: HyberInboxControllerMessageCell) {
    guard !tableView.editing else { return }
    changeEditMode(cell)
  }
  
}

extension HyberInboxController: InboxStyleDelegate {
  
  public func bubbleViewStyleDidChange() {
    
    visibleHeaderCells.forEach { (cell) in
      cell.updateStyle(.None)
    }
    
  }
  
}

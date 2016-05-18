//
//  HyberInboxController+Configure.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/19/16.
//
//

import Foundation
import UIKit

// MARK: - Edit mode change
internal extension HyberInboxController {
  
  func changeEditMode(cell: HyberInboxControllerMessageCell? = .None) {
    tableView.setEditing(!tableView.editing, animated: true)
    horizontalPanGestureRecognizer?.enabled = !tableView.editing
    configureEditMode(true, cell: cell)
  }
  
  func configureEditMode(
    animated: Bool,
    cell: HyberInboxControllerMessageCell? = .None) {
    
    let editing = tableView.editing
    
    setTabBarHidden(editing, animated: animated)
    
    setupNavigationBarItems(editing, animated: animated)
    
    // Shift sender name
    
    let visibleHeaderCells = self.visibleHeaderCells
    UIView.animateWithDuration(animated ? 0.3 : 0.0) {
      visibleHeaderCells.forEach {
        $0.setEditingMode(editing, animated: animated)
      }
    }
    
    guard editing else { return }
    
    // Select row, if cell passed
    if let
      cell = cell,
      selectedCellIndexPath = tableView.indexPathForCell(cell) //swiftlint:disable:this opening_brace
    {
      tableView.selectRowAtIndexPath(
        selectedCellIndexPath,
        animated: animated,
        scrollPosition: .None)
      
      setupToolbarItems(true)
      
    } else {
      
      setupToolbarItems()
      
    }
    
    // Deactivate search controller
    if searchController.active {
      searchController.active = false
    }
    
    // Scroll to selected cell
    if cell != .None {
      tableView.scrollToNearestSelectedRowAtScrollPosition(
        .None,
        animated: animated)
    }
    
  }
  
}

class CustomRefreshControl: UIControl {
  
  func containingScrollViewDidEndDragging(containingScrollView: UIScrollView) {
    let minOffsetToTriggerRefresh: CGFloat = 50.0
    if containingScrollView.contentOffset.y <= -minOffsetToTriggerRefresh {
      self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
  }
  
  func containingScrollViewDidScroll(containingScrollView: UIScrollView) {
    let minOffsetToTriggerRefresh: CGFloat = 50.0
    if containingScrollView.contentOffset.y <= -minOffsetToTriggerRefresh {
      self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
  }
  
}

// MARK: - Configuring
internal extension HyberInboxController {
  
  func configure() {
    
    edgesForExtendedLayout = [.Top, .Bottom]
    extendedLayoutIncludesOpaqueBars = true
    
    Hyber.helper.internalRemoteNotificationsDelegate = fetcher
    
    fetcher.delegate = self
    
    configureTableView()
    
    configureEditMode(false)
    
    addToolbarItems()
    
    configureHorizontalPanGesture()
    
    
    subscribeToLocalizationUpdates()
    
    localize()
        
    configureSearchController()
    searchController.searchBar.setShowsCancelButton(false, animated: false)
    
  }
  
  func configureTableView() {
    
    let headerCellNib = UINib(
      nibName: "HyberInboxControllerHeaderCell",
      bundle: Hyber.nonLocalizedBundle)
    let messageCellNib = UINib(
      nibName: "HyberInboxControllerMessageCell",
      bundle: Hyber.nonLocalizedBundle)
    let refreshCellNib = UINib(
      nibName: "HyberInboxControllerRefreshCell",
      bundle: Hyber.nonLocalizedBundle)
    
    tableView.registerNib(
      headerCellNib,
      forCellReuseIdentifier: "com.gms-worldwide.Hyber.HyberInboxControllerHeaderCell")
    tableView.registerNib(
      messageCellNib,
      forCellReuseIdentifier: "com.gms-worldwide.Hyber.HyberInboxControllerMessageCell")
    
    tableView.registerNib(
      refreshCellNib,
      forCellReuseIdentifier: "com.gms-worldwide.Hyber.HyberInboxControllerRefreshCell")
    
    tableView.allowsSelection = false
    tableView.allowsSelectionDuringEditing = true
    tableView.allowsMultipleSelectionDuringEditing = true
    tableView.separatorStyle = .None
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = UITableViewAutomaticDimension
    
    tableView.showsHorizontalScrollIndicator = false
    tableView.alwaysBounceHorizontal = false
    tableView.directionalLockEnabled = false
    
  }
  
}

public extension HyberInboxController {
  
  /**
   Localizes view controller
   */
  public func localize() {
    
    localizeSearchController()
    
    if tableView.editing {
      
      setupNavigationBarItems(tableView.editing, animated: true, overrideAnyway: true)
      
    }
    
  }
  
}

// MARK: - Localization
internal extension HyberInboxController {
  
  func subscribeToLocalizationUpdates() {
    hyberLocalizationDidChangeObserver = NSNotificationCenter.defaultCenter().addObserverForName(
      HyberLocalizationDidChangeNotification,
      object: .None,
      queue: .None) { [weak self] _ in
        self?.localize()
    }
  }
  
  func localizeSearchController() {
    
    let selected = self.selectedMessagesTypes
    self.selectedMessagesTypes = selected
    
    searchController.searchBar.placeholder = LocalizedStrings.UIKit.search
    
    if let cancelButton = searchController.searchBar.valueForKey("_cancelButton") as? UIButton {
      cancelButton.setTitle(LocalizedStrings.UIKit.cancel, forState: .Normal)
//      cancelButton.hidden = true
    } else {
      searchController.searchBar.subviews.first?.subviews.forEach() { subview in
//        print(NSStringFromClass(subview.dynamicType))
        if let subview = subview as? UIButton {
          subview.setTitle(LocalizedStrings.UIKit.cancel, forState: .Normal)
        }
      }
    }
    
    
  }
  
}

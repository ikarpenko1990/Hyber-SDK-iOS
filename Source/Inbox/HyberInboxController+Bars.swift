//
//  HyberInboxController+Bars.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/19/16.
//
//

import Foundation
import UIKit

// MARK: - Bar button actions
private extension HyberInboxController {
  
  private func deleteAllMessages(action: UIAlertAction) {
    let delete: Array<Int> = .init(0..<cellData.count)
    fetcher.delete(delete) { result in
      
      self.updateTableView(result, fetchingMessages: false)
      
      self.changeEditMode()
    }
  }
  
  @objc func deleteAllButtonPressed(sender: UIBarButtonItem) {
    
    let alert = UIAlertController(
      title: .None,
      message: .None,
      preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    let deleteAllAction = UIAlertAction(
      title: LocalizedStrings.deleteAll,
      style: UIAlertActionStyle.Destructive,
      handler: deleteAllMessages)
    
    let cancelAllAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: .None)
    
    alert.addAction(deleteAllAction)
    alert.addAction(cancelAllAction)
    
    presentViewController(alert, animated: true, completion: .None)
    
  }
  
  @objc func deleteSelectedItemsButtonPressed(sender: UIBarButtonItem) {
    if let indexPaths = tableView.indexPathsForSelectedRows {
      fetcher.delete(indexPaths.map { $0.row }) { result in
        
        self.updateTableView(result, fetchingMessages: false)
        
      }
    }
  }
  
  
  /**
   Void function for flexible space bar button
   */
  @objc func void() {}
  
  @objc func shareButtonPressed(sender: UIBarButtonItem) {
    
  }
  
}

// MARK: - Tab bar visibility
internal extension HyberInboxController {
  
  func setTabBarHidden(hidden: Bool, animated: Bool) {
    let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
    let toolBarHeight = navigationController?.toolbar.frame.height ?? 0
    let toolBarY = !hidden ? view.frame.size.height+1 : view.frame.size.height-toolBarHeight
    let duration = animated ? 0.3 : 0.0
    
    UIView.animateWithDuration(duration) { [weak self] in
      guard let sSelf = self else { return }
      if let tabBarController = sSelf.tabBarController {
        let viewHeight = sSelf.view.frame.size.height
        tabBarController.tabBar.frame.origin.y = hidden ? viewHeight + 1 : viewHeight - tabBarHeight
        tabBarController.tabBar.hidden = hidden
      }
      if let navigationController = sSelf.navigationController {
        navigationController.toolbar.hidden = !hidden
        navigationController.toolbar.frame.origin.y = toolBarY
      }
    }
  }
  
}

// MARK: - Navigation bar items
internal extension HyberInboxController {
  
  func setupNavigationBarItems(editing: Bool, animated: Bool, overrideAnyway: Bool = false) {
    if editing {
      if navigationItem.rightBarButtonItem?.action != #selector(changeEditMode) || overrideAnyway {
        
        let changeEditModeButton = UIBarButtonItem(
          barButtonSystemItem: .Done,
          target: self,
          action: #selector(changeEditMode))
        navigationItem.setRightBarButtonItem(changeEditModeButton, animated: animated)
        
        let deleteAllButton = UIBarButtonItem(
          title: LocalizedStrings.deleteAll,
          style: .Plain,
          target: self,
          action: #selector(deleteAllButtonPressed))
        navigationItem.setLeftBarButtonItem(deleteAllButton, animated: animated)
        
      }
    } else {
      if navigationItem.rightBarButtonItem != .None {
        navigationItem.setRightBarButtonItem(.None, animated: animated)
      }
      if navigationItem.leftBarButtonItem?.action != #selector(showFilter(_:)) || overrideAnyway {
        
        let showFilterButton = UIBarButtonItem(
          image: UIImage.filter,
          style: .Plain,
          target: self,
          action: #selector(showFilter(_:)))
        
        navigationItem.setLeftBarButtonItem(showFilterButton, animated: animated)
        
      }
    }
  }
  
}

// MARK: - Toolbar items
internal extension HyberInboxController {
  
  func setupToolbarItems(enabled: Bool? = .None) {
    let enabled = enabled ?? !(tableView.indexPathsForSelectedRows?.isEmpty ?? true)
    navigationController?.toolbar.items?.forEach { (item) in
      if item.enabled != enabled {
        item.enabled = enabled
      }
    }
  }
  
  func addToolbarItems() {
    let items = [
      
      UIBarButtonItem(
        barButtonSystemItem: .Trash,
        target: self,
        action: #selector(deleteSelectedItemsButtonPressed)),
      
      UIBarButtonItem(
        barButtonSystemItem: .FlexibleSpace,
        target: self,
        action: #selector(void))
      // TODO: sharing //swiftlint:disable:this todo
      //,
      
//      UIBarButtonItem(
//        image: UIImage.share,
//        style: UIBarButtonItemStyle.Plain,
//        target: self,
//        action: #selector(shareButtonPressed(_:)))
    ]
    navigationController?.toolbar.items = items
  }
  
}

//
//  HyberInboxController+SearchAndFilter.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/14/16.
//
//

import Foundation
import UIKit

// MARK: - Filtering
internal extension HyberInboxController {
  
  func showFilter(sender: UIBarButtonItem) {
    
    let filterController = HyberInboxFilterTableViewController(style: .Plain)
    filterController.selectedItems = selectedMessagesTypes
    filterController.preferredContentSize = CGSize(width: 200, height: 132)
    filterController.delegate = self
    filterController.modalPresentationStyle = .Popover
    filterController.tableView.bounces = false
    
    guard let filterPopover = filterController.popoverPresentationController else { return }
    
    filterPopover.sourceView = self.view
    filterPopover.sourceRect = view.frame
    filterPopover.delegate = self
    filterPopover.barButtonItem = sender
    
    presentViewController(filterController, animated: true, completion: .None)
    
  }
  
  private func filterSelectedMessagesTypesFilter(message: HyberMessageData) -> Bool {
    
    guard !selectedMessagesTypes.isEmpty else { return false }
    
    return selectedMessagesTypes.contains(message.type)
    
  }
  
  private func filter(message: HyberMessageData) -> Bool {
    
    let messageTypeFilter = filterSelectedMessagesTypesFilter(message)
    let searchFilter = searchIsActive ? filterSearchText(message) : true
    
    return messageTypeFilter && searchFilter
    
  }
  
  func updateFilter() {
    
    let shouldFilter = selectedMessagesTypes.count != HyberMessageType.allItems.count || searchIsActive
    
    let comletionHandler: (HyberInboxViewControllerMessageFetcherResult) -> Void = { (result) in
      self.updateTableView(
        result,
        fetchingMessages: false,
        scrollToBottom: false,
        scrollToLastPosition: false,
        animated: true,
        completionHandler: .None)
    }
    if shouldFilter {
      fetcher.setFilterClosure(filter, completionHandler: comletionHandler)
    } else {
      fetcher.setFilterClosure(.None, completionHandler: comletionHandler)
    }
    
  }
  
}

// MARK: - Configure search controller
extension HyberInboxController {
  
  func configureSearchBarScopeButtons() {
    
    let searchBar = searchController.searchBar
    
    if selectedMessagesTypes.count > 1 {
      searchBar.scopeButtonTitles = [LocalizedStrings.all] + selectedMessagesTypes.map { $0.description }
      if let selectedMessageType = selectedMessageType {
        if let index = selectedMessagesTypes.indexOf(selectedMessageType) {
          searchBar.selectedScopeButtonIndex = index + 1
        } else {
          self.selectedMessageType = .None
          searchBar.selectedScopeButtonIndex = 0
        }
      } else {
        searchBar.selectedScopeButtonIndex = 0
      }
    } else {
      searchBar.selectedScopeButtonIndex = 0
      searchBar.scopeButtonTitles = .None
      selectedMessageType = .None
    }
    
  }

  func configureSearchController() {
    searchController.searchBar.delegate = self
    configureSearchBarScopeButtons()
    searchController.searchBar.showsCancelButton = true
    searchController.searchBar.sizeToFit()
    
    searchController.searchResultsUpdater = self
    searchController.delegate = self
    
    // TODO: Search controller //swiftlint:disable:this todo
    //tableView.tableHeaderView = searchController.searchBar
    
    if #available(iOS 9.1, *) {
      searchController.obscuresBackgroundDuringPresentation = false
    } else {
      searchController.dimsBackgroundDuringPresentation = false
    }
    
    self.definesPresentationContext = true
    searchController.hidesNavigationBarDuringPresentation = true
    searchController.definesPresentationContext = false
    
  }
  
}

// MARK: - UISearchControllerDelegate
extension HyberInboxController: UISearchControllerDelegate {
  
  //swiftlint:disable missing_docs
  
  public func willPresentSearchController(searchController: UISearchController) {
    if tableView.editing {
      changeEditMode()
    }
  }
  
  public func didPresentSearchController(searchController: UISearchController) {
//    if searchController.searchBar.superview != .None
    searchController.view.setNeedsLayout()
    if searchController.active && searchController.searchBar.superview == .None {
      UIView.performWithoutAnimation {
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchController.searchBar.autoresizingMask = [.FlexibleWidth]
        searchController.view.addSubview(searchController.searchBar)
      }
    }
    searchController.searchBar.sizeToFit()
    searchController.searchBar.superview?.setNeedsLayout()
     searchController.searchBar.superview?.layoutIfNeeded()
    searchController.view.setNeedsUpdateConstraints()
    searchController.view.updateConstraintsIfNeeded()
    searchController.view.setNeedsLayout()
    searchController.view.layoutIfNeeded()
    searchController.searchBar.superview?.setNeedsUpdateConstraints()
    searchController.searchBar.superview?.updateConstraintsIfNeeded()
    searchController.searchBar.searchBarStyle = .Prominent
  }
  
  public func didDismissSearchController(searchController: UISearchController) {
    searchController.searchBar.showsScopeBar = false
    searchController.searchBar.showsCancelButton = false
    searchController.searchBar.sizeToFit()
//    searchController.searchBar.frame.size.height = 44.0
//    searchController.searchBar.sizeToFit()
//    selectedMessageType = .None
//    searchController.searchBar.selectedScopeButtonIndex = 0
    //tableView.tableHeaderView = searchController.searchBar
  }
  
  //swiftlint:enable missing_docs
  
}

// MARK: - UISearchResultsUpdating
extension HyberInboxController: UISearchResultsUpdating {
  
  private var searchIsActive: Bool {
    return searchController.active
      && (selectedMessageType != .None
        || !(searchController.searchBar.text?.isEmpty ?? true))
  }
  
  //swiftlint:disable missing_docs
  public func updateSearchResultsForSearchController(searchController: UISearchController) {
    
    updateFilter()
    
  } //swiftlint:enable missing_docs
  
  
  private func messagePassesScopeFilter(message: HyberMessageData) -> Bool {
    guard let selectedMessageType = selectedMessageType else { return true }
    return message.type == selectedMessageType
  }
  
  private func filterSearchText(message: HyberMessageData) -> Bool {
    guard let searchText = searchController.searchBar.text?.lowercaseString else {
      return messagePassesScopeFilter(message)
    }
    
    let words = searchText
      .componentsSeparatedByCharactersInSet(
        NSCharacterSet.whitespaceCharacterSet())
      .filter { !$0.isEmpty }
    
    guard !words.isEmpty else { return messagePassesScopeFilter(message) }
    
    var acceptable: Bool = false
    let messageBody = message.messageBody.lowercaseString
    let sender = message.sender.lowercaseString
    words.forEach { searchText in
      if !messageBody.isEmpty && messageBody.containsString(searchText) {
        acceptable = true
      }
      if !sender.isEmpty && sender.containsString(searchText) {
        acceptable = true
      }
    }
    if acceptable {
      acceptable = acceptable && messagePassesScopeFilter(message)
    }
    return acceptable
  }
}

// MARK: - UISearchBarDelegate
extension HyberInboxController: UISearchBarDelegate {
  
  //swiftlint:disable missing_docs
  public func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    if selectedScope < 1 {
      selectedMessageType = .None
    } else if (selectedScope - 1) < selectedMessagesTypes.count {
      selectedMessageType = selectedMessagesTypes[selectedScope - 1]
    } else {
      selectedMessageType = .None
    }
    updateFilter()
  } //swiftlint:enable missing_docs
  
}

// MARK: - UIPopoverPresentationControllerDelegate
extension HyberInboxController: UIPopoverPresentationControllerDelegate {
  
  //swiftlint:disable missing_docs
  public func adaptivePresentationStyleForPresentationController(
    controller: UIPresentationController)
    -> UIModalPresentationStyle //swiftlint:disable:this opening_brace
  {
    return .None
  } //swiftlint:enable missing_docs
  
}

// MARK: - InboxFilterTableDelegate
extension HyberInboxController: HyberInboxFilterTableDelegate {
  
  func inboxFilterTableViewController(
    controller: HyberInboxFilterTableViewController,
    didChangeSelectedItems selectedItems: [HyberMessageType]) //swiftlint:disable:this opening_brace
  {
    selectedMessagesTypes = selectedItems
  }
  
}

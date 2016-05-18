//
//  HyberInboxFilterTableViewController.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/14/16.
//
//

import Foundation
import UIKit

internal protocol HyberInboxFilterTableDelegate: class {
  
  func inboxFilterTableViewController(
    controller: HyberInboxFilterTableViewController,
    didChangeSelectedItems selectedItems: [HyberMessageType])
  
}

class HyberInboxFilterTableViewController: UITableViewController {
  
  weak var delegate: HyberInboxFilterTableDelegate? = .None
  
  let allItems = HyberMessageType.allItems
  
  var selectedItems: [HyberMessageType] {
    get {
      return _selectedItems
    }
    set {
      _selectedItems = newValue
    }
  }
  
  private var _selectedItems = [HyberMessageType]()
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allItems.count
  }
  
  private let cellID = "InboxFilterTableViewControllerCell"
  override func tableView(
    tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath)
    -> UITableViewCell //swiftlint:disable:this opening_brace
  {
    
    let cell: UITableViewCell
    if let dequeuedCell = tableView.dequeueReusableCellWithIdentifier(cellID) {
      cell = dequeuedCell
    } else {
      cell = UITableViewCell(style: .Default, reuseIdentifier: cellID)
    }
    
    cell.textLabel?.text = allItems[indexPath.row].description
    
    let selected = _selectedItems.indexOf(allItems[indexPath.row]) != .None
    
    cell.accessoryType = selected ? .Checkmark : .None
    
    return cell
    
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let messageType = allItems[indexPath.row]
    
    let selected: Bool
    if let selectedIndex = _selectedItems.indexOf(messageType) {
      _selectedItems.removeAtIndex(selectedIndex)
      selected = false
    } else {
      _selectedItems.append(messageType)
      selected = true
    }
    
    tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = selected ? .Checkmark : .None
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    delegate?.inboxFilterTableViewController(
      self,
      didChangeSelectedItems: _selectedItems.sort {$0.rawValue < $1.rawValue})
    
  }
  
}

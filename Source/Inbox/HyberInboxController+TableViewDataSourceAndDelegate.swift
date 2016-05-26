//
//  HyberInboxController+TableViewDataSourceAndDelegate.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/14/16.
//
//

import Foundation
import UIKit

// MARK: - UITableViewDelegate
extension HyberInboxController {
  
  public override func tableView(
    tableView: UITableView,
    estimatedHeightForRowAtIndexPath indexPath: NSIndexPath)
    -> CGFloat //swiftlint:disable:this opening_brace
  {
    return UITableViewAutomaticDimension
  }
  
  public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    setupToolbarItems(true)
  }
  
  public override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    setupToolbarItems()
  }
  
  public override func tableView(
    tableView: UITableView,
    heightForRowAtIndexPath indexPath: NSIndexPath)
    -> CGFloat //swiftlint:disable:this opening_brace
  {
    return UITableViewAutomaticDimension
  }
  
}

// MARK: - HyberInboxController
extension HyberInboxController {
  
  public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let numberOfRows = cellData.count + (fetchingMessages ? 1 : 0)
    return numberOfRows
  }
  
  public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override public func tableView(
    tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath)
    -> UITableViewCell //swiftlint:disable:this opening_brace
  {
    
    let cell: UITableViewCell
    
    let object: HyberInboxCellData
    if fetchingMessages && indexPath.row == 0 {
      object = HyberInboxCellData()
      
    } else {
      object = cellData[indexPath.row - (fetchingMessages ? 1 : 0)]
    }
    
    if object.isMessage {
      let inboxCell = tableView.dequeueReusableCellWithIdentifier(
        "com.gms-worldwide.Hyber.HyberInboxControllerMessageCell",
        forIndexPath: indexPath) as! HyberInboxControllerMessageCell //swiftlint:disable:this force_cast
      inboxCell.configure(object)
      inboxCell.inboxCellDelegate = self
      inboxCell.inboxStyle = sharedInboxStyle
      cell = inboxCell

    } else if object.isHeader {
      
      let headerCell = tableView.dequeueReusableCellWithIdentifier(
        "com.gms-worldwide.Hyber.HyberInboxControllerHeaderCell",
        forIndexPath: indexPath) as! HyberInboxControllerHeaderCell //swiftlint:disable:this force_cast
      
      headerCell.setEditingMode(tableView.editing, animated: false)
      headerCell.configure(object)
      headerCell.inboxStyle = sharedInboxStyle
      cell = headerCell
    } else if object.isRefresh {
      
      let inboxCell = tableView.dequeueReusableCellWithIdentifier(
        "com.gms-worldwide.Hyber.HyberInboxControllerRefreshCell",
        forIndexPath: indexPath) as! HyberInboxControllerRefreshCell //swiftlint:disable:this force_cast
      cell = inboxCell

    } else {
      
      cell = UITableViewCell()
    }
    
    return cell
    
  }
  
  public override func tableView(
    tableView: UITableView,
    canEditRowAtIndexPath indexPath: NSIndexPath)
    -> Bool //swiftlint:disable:this opening_brace
  {
    if fetchingMessages && indexPath.row == 0 {
      return false
    }
    return cellData[indexPath.row - (fetchingMessages ? 1 : 0)].isMessage
    
  }
  
}

//
//  HyberInboxController+MessageFetching.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/19/16.
//
//

import Foundation
import UIKit

// MARK: - Message fetching
public extension HyberInboxController {
  
  /**
   Fetches todays messages
   
   - parameter completionHandler: closure to run on fetch comletion
   */
  func fetchTodaysMesages(completionHandler: (() -> Void)? = .None) {
    stopTimer()
    guard !fetchingMessages else { startTimer(); return }
    updateTableView(.empty, fetchingMessages: true) { [weak self] in
      guard let sSelf = self else { return }
      sSelf.fetcher.fetchTodaysMessages(true) { [weak sSelf] result in
        guard let sSelf = sSelf else { return }
        
        sSelf.updateTableView(result, fetchingMessages: false) {
          if sSelf.isVisible == true {
            sSelf.startTimer()
          }
            completionHandler?()          
        }
      }
    }
  }
  
  /**
   Fetches previous messages
   
   - parameter scrollToBottom: `true` - scroll to bottom on fetch finish, `false` - otherwise
   - parameter completionHandler: closure to run on fetch comletion
   */
  func loadPreviousMessages(scrollToBottom: Bool = false, completionHandler: (() -> Void)? = .None) {
    guard fetcher.hasMorePrevious && !fetchingMessages else { return }
    updateTableView(.empty, fetchingMessages: true) { [weak self] in

      guard let sSelf = self else { return }
    
      sSelf.fetcher.loadPrevious() { [weak self] (result) in
        guard let sSelf = self else { return }
        
        let completion: () -> Void = {
          
          
          if sSelf.tableView.bounds.height > sSelf.tableView.contentSize.height
            && sSelf.fetcher.hasMorePrevious
            && !sSelf.fetchingMessages //swiftlint:disable:this opening_brace
          {
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC)))
            dispatch_after(delay, dispatch_get_main_queue(), {
              sSelf.loadPreviousMessages(scrollToBottom, completionHandler: completionHandler)
            })
          }
          
        }
        
        sSelf.updateTableView(
        result,
        fetchingMessages: sSelf.fetcher.fetchingPreviousMessages && sSelf.fetcher.hasMorePrevious,
        scrollToBottom: scrollToBottom,
        scrollToLastPosition: !scrollToBottom) {
          completion()
        }
        
      }
      
    }
  }
  
}

// MARK: Fetch todays messages timer
private extension HyberInboxController {
  
  /// Starts auto-fetch delivered messages timer
  func startTimer() {
    stopTimer()
    todaysMesagesUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(
      todaysMesagesUpdateInterval,
      target: self,
      selector: #selector(fetchTodaysMesagesTimerFired(_:)),
      userInfo: .None,
      repeats: false)
  }
  
  /// Stops auto-fetch delivered messages timer
  func stopTimer() {
    todaysMesagesUpdateTimer?.invalidate()
    todaysMesagesUpdateTimer = .None
  }
  
  /**
   Wrapper for `todaysMesagesUpdateTimer selector`
   
   - parameter sender: fired `NSTimer`
   */
  @objc func fetchTodaysMesagesTimerFired(sender: NSTimer) {
    fetchTodaysMesages()
  }
  
}

// MARK: - InboxViewControllerMessageFetcherDelegate
extension HyberInboxController: HyberInboxViewControllerMessageFetcherDelegate {
  
  func newMessagesFetched(diff: HyberInboxViewControllerMessageFetcherResult) {
    
    updateTableView(diff, fetchingMessages: false, scrollToBottom: true, animated: true)
    
  }
  
}

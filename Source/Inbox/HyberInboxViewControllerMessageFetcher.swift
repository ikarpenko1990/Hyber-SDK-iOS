//
//  InboxViewControllerMessageFetcher.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/7/16.
//
//

import Foundation

// swiftlint:disable opening_brace
// swiftlint:disable type_body_length
// swiftlint:disable file_length
/**
 The delegate of a `InboxViewControllerMessageFetcher` object must adopt the
 `InboxViewControllerMessageFetcherDelegate` protocol.
 Delegate object must implement `newMessagesFetched()` method
 */
internal protocol HyberInboxViewControllerMessageFetcherDelegate: class {
  /**
   Calls when new remote push-notification delivered
   */
  func newMessagesFetched(diff: HyberInboxViewControllerMessageFetcherResult)
  
}

/**
 Message fetcher for `InboxViewController`
 */
public class HyberInboxViewControllerMessageFetcher {
  /**
   Shared `InboxViewControllerMessageFetcher` object.
   */
  static let sharedInstance = HyberInboxViewControllerMessageFetcher()
  
  /// Serial operation queue
  let serialOperationQueue = SerialOperationQueue()
  
  /**
   Delegate
   */
  internal weak var delegate: HyberInboxViewControllerMessageFetcherDelegate? = .None
  
  /// Messages filtered. `true` if `filterClosure` is not `nil`, `false` otherwise
  public var filtered: Bool {
    return filterClosure != nil
  }
  
  /**
   Closure to filter messages. Recieves one parameter of `HyberMessageData` type.
   Returns `true`, if message shoud be included in cellData, `false` - otherwise
   */
  private var filterClosure: ((HyberMessageData) -> Bool)? = .None
  
  func setFilterClosure(
    filterClosure: ((HyberMessageData) -> Bool)? = .None,
    completionHandler: ((HyberInboxViewControllerMessageFetcherResult) -> Void)? = .None)
  {
    
    let oldData = self.cellData
    if let filterClosure = filterClosure {
      self.filteredMessages = self.rawMessages.filter(filterClosure)
      self.filteredCellData = self.generatedCellDataFrom(self.filteredMessages)
    }
    self.filterClosure = filterClosure
    
    completionHandlerInMainThread(completionHandler)?(self.diff(oldData, after: self.cellData))
    
  }
  
  /**
   Executes passed block for filtered and raw data
   
   - parameter block: Block to run, when messages fetched.
   - parameter rawData: raw data
   - parameter cellData: cell data
   The block takes three parameters and have no return value.
   Block parametrs:
   - parameter filtered: `true` if operating with filtered data, `false` otherwise (read-only)
   - parameter rawData: `Array<HyberMessageData>` (`inout`)
   - parameter cellData: `Array<HyberInboxCellData>` (`inout`)
   
   */
  func executeBlockWithData( //swiftlint:disable:this valid_docs
    @noescape block: (filtered: Bool,
    inout rawData: [HyberMessageData],
    inout cellData: [HyberInboxCellData]) -> Void) //swiftlint:disable:this opening_brace
  {
    
    var filteredMessages = self.filteredMessages
    var rawMessages = self.rawMessages
    var filteredCellData = self.filteredCellData
    var rawCellData = self.rawCellData
    
    for filtered in [false, true] {
      var rawData = filtered ? self.filteredMessages : self.rawMessages
      var cellData = filtered ? self.filteredCellData : self.rawCellData
      
      if filtered && !self.filtered {
        continue
      }
      
      block(filtered: filtered, rawData: &rawData, cellData: &cellData)
      
      if !filtered {
        rawMessages = rawData
        rawCellData = cellData
      } else {
        filteredMessages = rawData
        filteredCellData = cellData
      }
    }
    
    self.filteredMessages = filteredMessages
    self.rawMessages = rawMessages
    self.filteredCellData = filteredCellData
    self.rawCellData = rawCellData
    
  }
  
    
  /// Private initializer
  private init() {
    Hyber.helper.internalRemoteNotificationsDelegate = self
		NSNotificationCenter.defaultCenter()
			.addObserver(self,
			             selector: #selector(hyberDidSignOut(_:)),
			             name: kHyberDidSignOut,
			             object: .None)
  }
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	@objc func hyberDidSignOut(notification: NSNotification) {
		self.signOut()
	}
  
  /// Earliest fetched date
  private var lastFetchedDate = NSDate(timeInterval: -0.001, sinceDate: NSDate().startOfDay())
  
  /// Fetched `HyberMessageData` messages
  internal private (set) var rawMessages = [HyberMessageData]()
  
  /// Filtered `HyberMessageData` messages
  internal private (set) var filteredMessages = [HyberMessageData]()
  
  /// Filtered cell data
  private var _filteredCellData = [HyberInboxCellData]()
  private var filteredCellData: [HyberInboxCellData] {
    get {
      return _filteredCellData
    }
    set {
      self._filteredCellData = newValue
    }
  }
  
  /// Unfiltered cell data
  private var _rawCellData = [HyberInboxCellData]()
  private var rawCellData: [HyberInboxCellData] {
    get {
      return _rawCellData
    }
    set {
      self._rawCellData = newValue
    }
  }
  
  /// Cell data objects
  var _cellData = [HyberInboxCellData]() //swiftlint:disable:this variable_name
  var cellData: [HyberInboxCellData] {
    self._cellData = self.filtered ? self.filteredCellData : self.rawCellData
    return _cellData
  }
  
  /// OTTBulkPlatform launched date
  private let ottPlatformLaunchDate = NSDate(timeIntervalSinceReferenceDate: 473299200)
  
  /// Retuns `true` if can fetch more erlier messages, `false othrewise`
  internal var hasMorePrevious: Bool {
    return lastFetchedDate.startOfDay().timeIntervalSinceDate(minLastFetchedDate.startOfDay()) > 0
  }
  
  /**
   Returns minimum available `NSDate` to fetch earlier messages
   - Returns: minimum available `NSDate` to fetch earlier messages
   */
  private var minLastFetchedDate: NSDate {
    let startTimeInterval =
      (Hyber.registeredUser?.registrationDate
        ?? ottPlatformLaunchDate)
        .timeIntervalSinceReferenceDate
    
    let endTimeInterval = NSDate(timeInterval: -7 * 86400, sinceDate: NSDate().startOfDay())
      .timeIntervalSinceReferenceDate
    
    return NSDate(timeIntervalSinceReferenceDate: max(startTimeInterval, endTimeInterval))
    
  }
  
  /**
   Fetching todays messages (with delivered date is today)
   
   - Parameter fetch: `Bool` indicates to fetch message from remote server if no stored data available.
   `true` - fetch data if there is no cached data, `false` otherwise. Default value is `true`.
   
   - Parameter completionHandler: Closure to run, when messages fetched.
   The closure should take no parameters and have no return value.
   */
  internal func fetchTodaysMessages(
    fetch: Bool = true,
    completionHandler: ((HyberInboxViewControllerMessageFetcherResult) -> Void)? = .None) //swiftlint:disable:this line_length
  {
    
    HyberMessagesFetcher.fetchMessages(forDate: NSDate(), fetch: fetch) { [weak self] result in
      
      guard let
        sSelf = self,
        todaysMessages = result.value where !todaysMessages.isEmpty
        else {
          completionHandlerInMainThread(completionHandler)?(.empty)
          return
      }
      
      let newMessages = todaysMessages
        .sort {
          return $0.deliveredDate.timeIntervalSinceReferenceDate
            > $1.deliveredDate.timeIntervalSinceReferenceDate
      }
      
      let oldCellData = sSelf.cellData
      
      sSelf.synchronized({ [weak sSelf] in
        
        guard let sSelf = sSelf else { return }
        
        sSelf.executeBlockWithData { (filtered, rawData, cellData) in
          newMessages.forEach { (message) in
            guard !filtered
              || (sSelf.filterClosure?(message) ?? true)
              else { return }
            if rawData.indexOf({ message == $0 }) == .None {
              if let index = rawData.indexOf({
                $0.deliveredDate.timeIntervalSinceReferenceDate
                  > message.deliveredDate.timeIntervalSinceReferenceDate }) //swiftlint:disable:this line_length
                
              {                 rawData.insert(message, atIndex: index)
              } else {
                rawData.append(message)
              }
              
            }
          }
        }
        
        sSelf.rawCellData = sSelf.generatedCellDataFrom(sSelf.rawMessages)
        if sSelf.filtered {
          sSelf.filteredCellData = sSelf.generatedCellDataFrom(sSelf.filteredMessages)
        }
        
        }, completionBlock: { [weak sSelf] in
          
          guard let sSelf = sSelf else { return }
          
          let diff = sSelf.diff(oldCellData, after: sSelf.cellData)
          completionHandlerInMainThread(completionHandler)!(diff)
          
        }
      )
      
    }
  }
  
  /**
   `Bool` flag, that has value `true` if there are fetch messages job is active, `false` otherwise
   */
  internal private (set) var fetchingPreviousMessages: Bool = false 
  
  /**
   Fetching previous messages
   
   - Parameter completionHandler: Closure to run, when messages fetched.
   The closure should take no parameters and have no return value.
   */
  internal func loadPrevious(
    completionHandler: ((HyberInboxViewControllerMessageFetcherResult) -> Void)? = .None) //swiftlint:disable:this line_length
  {
    
    if fetchingPreviousMessages {
      completionHandlerInMainThread(completionHandler)?(.empty)
      return
    }
    fetchingPreviousMessages = true
    
    let completion: (HyberInboxViewControllerMessageFetcherResult) -> Void = { [weak self] (result) -> Void in
      self?.fetchingPreviousMessages = false
      completionHandlerInMainThread(completionHandler)?(result)
    }
    
    loadPreviousMessages(completion)
    
  }
  
  /**
   Fetching previous messages (private)
   
   - Parameter completionHandler: Closure to run, when messages fetched.
   The closure should take no parameters and have no return value.
   
   */
  private func loadPreviousMessages(
    completionHandler: (HyberInboxViewControllerMessageFetcherResult) -> Void) //swiftlint:disable:this line_length
  {

    HyberMessagesFetcher.fetchMessages(forDate: lastFetchedDate) { [weak self] result in
      
      guard let sSelf = self else {
        completionHandler(.empty)
        return
      }
      guard var messages = result.value else {
        completionHandler(.empty)
        return
      }
      
      if messages.isEmpty {
        sSelf.synchronized_wait {
          sSelf.lastFetchedDate = sSelf.lastFetchedDate.previousDay()
        }
        if sSelf.hasMorePrevious {
          sSelf.loadPreviousMessages(completionHandler)
        } else {
          completionHandler(.empty)
        }
        return
      }
      
      messages
        .sortInPlace {
          return $0.deliveredDate.timeIntervalSinceReferenceDate
            < $1.deliveredDate.timeIntervalSinceReferenceDate
      }
      
      sSelf.synchronized {
        
        let oldCellData = sSelf.cellData
        
        sSelf.executeBlockWithData { (filtered, rawData, cellData) in
          
          let recievedMessages = filtered ? messages.filter({ sSelf.filterClosure?($0) ?? false }) : messages
          
          let firstMessageData = cellData.first
          let firstRawDataMessage = rawData.first
          
          rawData = recievedMessages + rawData
          
          let newCellData = sSelf.generatedCellDataFrom(recievedMessages)
          
          if let
            firstMessageData = firstMessageData where firstMessageData.isHeader,
            let firstRawDataMessage = firstRawDataMessage //swiftlint:disable:this opening_brace
          {
            if let headerCellData = sSelf.cellDataFor(
              recievedMessages.first,
              currentMessage: firstRawDataMessage,
              nextMessage: .None)
              .filter ({ $0.isHeader })
              .first {
              cellData[0] = headerCellData
            }
          }
          
          cellData = newCellData + cellData
          
          sSelf.lastFetchedDate = sSelf.lastFetchedDate.previousDay()
          
        }
        
        let diff = sSelf.diff(oldCellData, after: sSelf.cellData)
        completionHandlerInMainThread(completionHandler)!(diff)
        
      }
      
    }
  }
  
  let styler: HyberInboxControllerStyle = HyberInboxControllerStyler()
  
  @warn_unused_result
  func generatedCellDataFrom(messages: [HyberMessageData]) -> [HyberInboxCellData] {
    guard !messages.isEmpty else { return [] }
    var cellData = [HyberInboxCellData]()
    
    let messagesCount = messages.count
    
    for index in 0..<messagesCount {
      
      let previousMessage: HyberMessageData? = index > 0 ? messages[index - 1] : .None
      let currentMessage = messages[index]
      let nextMessage: HyberMessageData? = (index < (messagesCount - 1)) ? messages[index + 1] : .None
      cellData += cellDataFor(previousMessage, currentMessage: currentMessage, nextMessage: nextMessage)
      
    }
    
    return cellData
    
  }
  
  @warn_unused_result
  func cellDataFor(
    previousMessage: HyberMessageData?,
    currentMessage: HyberMessageData,
    nextMessage: HyberMessageData?)
    -> [HyberInboxCellData] //swiftlint:disable:this opening_brace
  {
    
    var cellData = [HyberInboxCellData]()
    
    let shouldDisplayFlags = self.shouldDisplayFlags(previousMessage, currentMessage, nextMessage)
    
    if shouldDisplayFlags.shouldDisplayHeader {
      cellData.append(
        HyberInboxCellData(
          message: currentMessage,
          showMessageType: shouldDisplayFlags.showMessageType,
          showTime: shouldDisplayFlags.showTime,
          showSenderTitle: shouldDisplayFlags.showSenderTitle,
          indentAvatar: shouldDisplayFlags.indentAvatar))
    }
    
    cellData.append(
      HyberInboxCellData(
        message: currentMessage,
        indentAvatar: shouldDisplayFlags.indentAvatar,
        showAvatar: shouldDisplayFlags.showAvatar))
    
    return cellData
    
  }
  
  private (set) var timeIntervalForHeaderTimeDisplay: NSTimeInterval = 20.0 * 60.0
  
  /**
   Remove and return the element at `index`
   - Parameter indecies: indecies of elements to delete
   - Parameter completionHandler: clousure to run after deletion
   */
  func delete(
    indecies: [Int],
    completionHandler: ((HyberInboxViewControllerMessageFetcherResult) -> Void)? = .None) //swiftlint:disable:this line_length
  {
    let oldCellData = self.cellData
    
    self.synchronized {
      
      let oldData = self.cellData
      
      indecies.forEach { (deletedItemIndex) in
        
        guard oldData.count > deletedItemIndex && deletedItemIndex >= 0 else { return }
        
        let currentCellData = oldData[deletedItemIndex]
        let message = currentCellData.message
        
        if let index = self.rawMessages.indexOf({ message == $0 }) {
          self.rawMessages.removeAtIndex(index)
        }
        
        if let index = self.filteredMessages.indexOf({ message == $0 }) {
          self.filteredMessages.removeAtIndex(index)
        }
        
        message?.delete()
        
      }
      
      self.rawCellData = self.generatedCellDataFrom(self.rawMessages)
      self.filteredCellData = self.generatedCellDataFrom(self.filteredMessages)
      
      let diff = self.diff(oldCellData, after: self.cellData)
      completionHandlerInMainThread(completionHandler)?(diff)
      
    }
    
  }
  
  func signOut() {
    setFilterClosure(.None, completionHandler: .None)
    executeBlockWithData { (filtered, rawData, cellData) in
      rawData = []
      cellData = []
    }
    self.lastFetchedDate = NSDate(timeInterval: -0.001, sinceDate: NSDate().startOfDay())
  }
  
}

extension HyberInboxViewControllerMessageFetcher: HyberRemoteNotificationReciever {
  
	public func didReceiveRemoteNotification(
		userInfo: [NSObject : AnyObject],
		pushNotification: HyberPushNotification) // swiftlint:disable:this opening_brace
	{
		
		let message = HyberMessage(pushNotification: pushNotification)
		synchronized { [weak self] in
			
			guard let sSelf = self else { return }
			
			let oldCellData = sSelf.cellData
			
			sSelf.executeBlockWithData { (filtered, rawData, cellData) in
				
				if filtered && !(sSelf.filterClosure?(message) ?? true) {
					return
				}
				
				let lastMessage = rawData.last
				
				var newCells: [HyberInboxCellData]
				if let lastMessage = lastMessage where rawData.count > 1 {
					newCells = sSelf.cellDataFor(
						rawData[rawData.count - 2],
						currentMessage: lastMessage,
						nextMessage: message)
						.filter { $0.isMessage }
					cellData.removeLast()
				} else {
					newCells = []
				}
				
				newCells += sSelf.cellDataFor(lastMessage, currentMessage: message, nextMessage: .None)
				
				rawData.append(message)
				cellData += newCells
			}
			
			let diff = sSelf.diff(oldCellData, after: sSelf.cellData)
			dispatch_sync(dispatch_get_main_queue()) {
				sSelf.delegate?.newMessagesFetched(diff)
			}
			
		}
		
	}
	
}
//swiftlint:enable opening_brace
//swiftlint:enable type_body_length
//swiftlint:enable file_length

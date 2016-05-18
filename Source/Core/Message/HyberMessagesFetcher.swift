//
//  HyberMessagesFetcher.swift
//  Hyber
//
//  Created by Vitalii Budnik on 1/25/16.
//
//

import Foundation
import CoreData

/**
 `Class` fetches delivered messages from Global Message Services servers
 */
public final class HyberMessagesFetcher {
    
  /// Private initializer
  private init() {
    
  }
  
  /**
   Fetches messages from Global Message Services servers
   - Parameter date: `NSDate` concrete date for which you need to get messages
   - Parameter fetch: `Bool` indicates to fetch message from remote server if no stored data available.
   `true` - fetch data if there is no cached data, `false` otherwise. Default value is `true`
   - Parameter completionHandler: The code to be executed once the request has finished. (optional). 
  This block takes no parameters. 
  Returns `Result` `<[HyberMessageData], HyberError>`, where `result.value`
  is always contains `Array<GMSMessage>` if there no error occurred, otherwise see `result.error`
   */
  public class func fetchMessages(
    forDate date: NSDate,
    fetch: Bool = true,
    completionHandler: ((HyberResult<[HyberMessageData]>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    let completion = completionHandler
    
    if !Hyber.authorized {
      completion?(.Failure(.NotAuthorized))
    }
    
    if date.timeIntervalSinceReferenceDate > NSDate().timeIntervalSinceReferenceDate {
      completion?(.Success([]))
    }
    
    let lastFetchedTimeInterval: NSTimeInterval
    
    let moc = HyberCoreDataHelper.newManagedObjectContext()
    let gmsMessages: [HyberMessageData]
    if let fetchedDate = HyberDataInboxFetchedDate.getHyberDataInboxFetchedDate(
      forDate: date.timeIntervalSinceReferenceDate,
      inManagedObjectContext: moc) // swiftlint:disable:this opening_brace
    {
      let messages: [HyberDataInboxMessage]
      // swiftlint:disable empty_count
      if let fetchedMessages = fetchedDate.messages where fetchedMessages.count > 0 {
        // swiftlint:enable empty_count
        messages = (fetchedMessages.allObjects as? [HyberDataInboxMessage])?.filter { !$0.deletionMark } ?? []
      } else {
        messages = []
      }
      gmsMessages = messages
        .filter { !$0.deletionMark }
        .flatMap { HyberMessage(message: $0) }
      
      if fetchedDate.lastMessageDate == date.endOfDay().timeIntervalSinceReferenceDate
//      && fetchedDate.lastMessageDate != NSDate().endOfDay().timeIntervalSinceReferenceDate
      {
        completion?(.Success(gmsMessages))
        return
      }
      lastFetchedTimeInterval = fetchedDate.lastMessageDate
    } else {
      gmsMessages = []
      lastFetchedTimeInterval = date.startOfDay().timeIntervalSinceReferenceDate
    }
    
    if !fetch {
      completion?(.Success(gmsMessages))
      return
    }
    
    fetchSMS(forDate: lastFetchedTimeInterval) { result in
      
      guard let sms: [HyberMessageData] = result.value(completionHandler) else { return }
      
      HyberMessagesFetcher.fetchViber(forDate: lastFetchedTimeInterval) { result in
        
        guard let viber = result.value(completionHandler) else { return }
        
        HyberMessagesFetcher.fetchPushNotifications(
          forDate: lastFetchedTimeInterval) { result in
            
            guard let push = result.value(completionHandler) else { return }
            
            completion?(.Success(sms + viber + push))
            
        }
      }
    }
  }
  
  /**
   Fetches `.Viber` messages from Global Message Services servers
   - Parameter date: `NSTimeInterval` concrete time interval
   *since 00:00:00 UTC on 1 January 2001* for which you need to get messages
   - Parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. 
   Returns `Result` `<[HyberMessageData], HyberError>`, where `result.value`
   is always contains `Array<GMSMessage>` if there no error occurred, otherwise see `result.error`
   */
  private class func fetchViber(
    forDate date: NSTimeInterval,
    completionHandler completion: (HyberResult<[HyberMessageData]>) -> Void) // swiftlint:disable:this line_length
  {
    fetch(.Viber, date: date, completionHandler: completion)
  }
  
  /**
   Fetches `.SMS` messages from Global Message Services servers
   - Parameter date: `NSTimeInterval` concrete time interval
   *since 00:00:00 UTC on 1 January 2001* for which you need to get messages
   - Parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. 
   Returns `Result` `<[HyberMessageData], HyberError>`, where `result.value`
   is always contains `Array<GMSMessage>` if there no error occurred, otherwise see `result.error`
   */
  private class func fetchSMS(
    forDate date: NSTimeInterval,
    completionHandler completion: (HyberResult<[HyberMessageData]>) -> Void) // swiftlint:disable:this line_length
  {
    fetch(.SMS, date: date, completionHandler: completion)
  }
  
  /**
   Gets recieved push-notification from `HyberDataInboxFetchedDate`
   - Parameter date: `NSTimeInterval` concrete time interval
   *since 00:00:00 UTC on 1 January 2001* for which you need to get messages
   - Parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. 
   Returns `Result` `<[HyberMessageData], HyberError>`, where `result.value`
   is always contains `Array<GMSMessage>` if there no error occurred, otherwise see `result.error`
   */
  private class func fetchPushNotifications(
    forDate date: NSTimeInterval,
    completionHandler completion: (HyberResult<[HyberMessageData]>) -> Void) // swiftlint:disable:this line_length
  {
    
    completion(.Success(getPushNotifications(forDate: date)))
    
  }
  
  /**
   Gets recieved push-notification from `HyberDataInboxFetchedDate`
   - Parameter date: `NSTimeInterval` concrete time interval
   *since 00:00:00 UTC on 1 January 2001* for which you need to get messages
   - Returns: An array of recieved `HyberMessageData`s
   */
  public class func getPushNotifications(forDate date: NSTimeInterval) -> [HyberMessageData] {
    
    let managedObjectContext = HyberCoreDataHelper.newManagedObjectContext()
        guard let fetchedDate = HyberDataInboxFetchedDate.getHyberDataInboxFetchedDate(
          forDate: date,
          inManagedObjectContext: managedObjectContext) else { return [] }
        if let messages = fetchedDate.messages?.flatMap({ $0 as? HyberDataInboxMessage }) {
          return messages
            .filter {
              !$0.deletionMark &&
                $0.type == HyberMessageType.PushNotification.rawValue }
            .flatMap { HyberMessage(message: $0) }
        }
        return []
//      }
  }
  
  /**
   Fetches messages of concrete type from Global Message Services servers
   - Parameter type: `HyberMessageType` concrete type of messages which you need to get
   - Parameter date: `NSTimeInterval` concrete time interval
   *since 00:00:00 UTC on 1 January 2001* for which you need to get messages
   - Parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. 
   Returns `Result` `<[HyberMessageData], HyberError>`, where `result.value` 
   is always contains `Array<GMSMessage>` if there no error occurred, otherwise see `result.error`
   */
  private class func fetch(
    type: HyberMessageType,
    date: NSTimeInterval,
    completionHandler completion: (HyberResult<[HyberMessageData]>) -> Void) // swiftlint:disable:this line_length
  {
    
    let errorCompletion: (HyberError) -> Void = { error in
      completion(.Failure(error))
    }
    
    let gmsToken = Hyber.registeredGMStoken
    if gmsToken <= 0 {
      errorCompletion(.GMSTokenIsNotSet)
      return
    }
    
    guard let phone = Hyber.registeredUserPhone else {
      errorCompletion(.MessageFetcherError(.NoPhone))
      return
    }
    
    let urlString: String = "requestMessages/" + type.requestSuffix()
    
    let timeInterval = UInt64(
      floor(
        NSDate(timeIntervalSinceReferenceDate: date).timeIntervalSince1970 * 1000))
    
    let parameters: [String: AnyObject] = [
      "uniqAppDeviceId": NSNumber(unsignedLongLong: gmsToken),
      "phone": NSNumber(unsignedLongLong: phone),
      "date_utc": NSNumber(unsignedLongLong: timeInterval)
    ]
    
    let requestTime = NSDate().timeIntervalSinceReferenceDate
    
    let completionHandler = messagesFetchHandler(
      type,
      date: date,
      requestTime: requestTime,
      completionHandler: completion)
    
    HyberProvider.sharedInstance.POST(
      .OTTPlatform,
      urlString,
      parameters: parameters,
      checkStatus: false,
      completionHandler: completionHandler
    )
  }
  
  /**
   Fetches messages of concrete type from Global Message Services servers
   - Parameter type: `HyberMessageType` concrete type of messages which you need to get
   - Parameter date: `NSTimeInterval` concrete time interval
   *since 00:00:00 UTC on 1 January 2001* for which you need to get messages
   - Parameter requestTime: `NSTimeInterval` *since 00:00:00 UTC on 1 January 2001* when request was sended
   - Parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. 
   Returns `Result` `<[HyberMessageData], HyberError>`, where `result.value`
   is always contains `Array<GMSMessage>` if there no error occurred, otherwise see `result.error`
   - Returns: Closure that fetches messages and saves it to CodeData DB and executes passed 
   `completionHandler` with result
   */
  private class func messagesFetchHandler(
    type: HyberMessageType,
    date: NSTimeInterval,
    requestTime: NSTimeInterval,
    completionHandler completion: (HyberResult<[HyberMessageData]>) -> Void)
    -> (HyberResult<[String : AnyObject]>) -> Void  // swiftlint:disable:this line_length
  {
    return { response in
      
      guard let fullJSON: [String : AnyObject] = response.value(completion) else {
        hyberLog.error((response.error ?? HyberError.UnknownError).localizedDescription)
        return
      }
      
      guard let incomeMessages = fullJSON["messages"] as? [[String: AnyObject]] else {
        completion(.Success([]))
        return
      }
      
      let messages = incomeMessages
        .flatMap {
          (HyberMessage(
            dictionary: $0,
            andType: type) as! HyberMessageData) //swiftlint:disable:this force_cast
      }
      
      HyberMessagesFetcher.saveMessages(
        messages,
        date: date,
        requestTime: requestTime,
        completionHandler: completion)
      
    }
  }
  
  /**
   Fetches messages of concrete type from Global Message Services servers
   - Parameter messages: `[HyberMessageData]` an array of recieved messages
   - Parameter date: `NSTimeInterval` concrete date for which you need to get messages
   - Parameter requestTime: `NSTimeInterval` *since 00:00:00 UTC on 1 January 2001* when request was sended
   - Parameter completionHandler: The code to be executed once the request has finished. 
   (optional). This block takes no parameters.
   Returns `Result` `<[HyberMessageData], HyberError>`, where `result.value` 
   is always contains `Array<GMSMessage>` if there no error occurred, otherwise see `result.error`
   */
  private class func saveMessages(
    messages: [HyberMessageData],
    date: NSTimeInterval,
    requestTime: NSTimeInterval,
    completionHandler completion: (HyberResult<[HyberMessageData]>) -> Void) // swiftlint:disable:this line_length
  {
    
    let managedObjectContext = HyberCoreDataHelper.newManagedObjectContext()
    
    var deletedMessages = [HyberMessageData]()
    messages.forEach() { message in
      
      guard let coreDataMessage = HyberDataInboxMessage.findObject(
        withPredicate: message.searchPredicate(),
        inManagedObjectContext: managedObjectContext) as? HyberDataInboxMessage
        else { return }
      
      coreDataMessage.messageID       = NSDecimalNumber(unsignedLongLong: message.id)
      coreDataMessage.message         = message.messageBody
      coreDataMessage.deliveredDate   = message.deliveredDate.timeIntervalSinceReferenceDate
      coreDataMessage.type            = message.type.rawValue
      
      coreDataMessage.setSenderNameString(message.sender)

      coreDataMessage.setFethcedDate()
      
      if coreDataMessage.deletionMark {
        deletedMessages.append(message)
      }
      
    }
    
    if messages.isEmpty {
      let fetchedDate = HyberDataInboxFetchedDate.getHyberDataInboxFetchedDate(
        forDate: date,
        inManagedObjectContext: managedObjectContext,
        createNewIfNotFound: true)
      
      //let date = NSDate(timeIntervalSinceReferenceDate: date)
      if let fetchedDate = fetchedDate {
        if NSDate(timeIntervalSinceReferenceDate: date).startOfDay().timeIntervalSinceReferenceDate
          == NSDate().startOfDay().timeIntervalSinceReferenceDate //swiftlint:disable:this opening_brace
        {
          fetchedDate.lastMessageDate = requestTime
        } else if date > NSDate().endOfDay().timeIntervalSinceReferenceDate {
          fetchedDate.lastMessageDate = NSDate(timeIntervalSinceReferenceDate: date)
            .startOfDay().timeIntervalSinceReferenceDate
        } else {
          fetchedDate.lastMessageDate = NSDate(timeIntervalSinceReferenceDate: date)
            .endOfDay()
            .timeIntervalSinceReferenceDate
        }
      }
      
    }
    
    let result = managedObjectContext.saveSafeRecursively()
    switch result {
    case .Failure(let error):
      completion(.Failure(error))
      break
    case .Success:
      completion(.Success(messages.filter { message -> Bool in
        return deletedMessages.indexOf({ message == $0}) == .None }))
      break
    }
  }
  
}

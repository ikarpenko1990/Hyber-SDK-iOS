//
//  HyberProvider.swift
//  Hyber
//
//  Created by Vitalii Budnik on 12/15/15.
//
//

import Foundation

/**
 Generates `POST`s requests to Global Message Services servers
 */
internal class HyberProvider {
  
	/**
   Default ephemeral `NSURLSessionConfiguration`
	*/
	private let sessionConfiguration: NSURLSessionConfiguration = {
		
		let sessionConfiguration: NSURLSessionConfiguration
		
		sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
		
		sessionConfiguration.HTTPAdditionalHeaders         = defaultHTTPAdditionalHeaders
		
		sessionConfiguration.HTTPMaximumConnectionsPerHost = 10
		sessionConfiguration.URLCache                      = .None
		sessionConfiguration.URLCredentialStorage          = .None
		sessionConfiguration.requestCachePolicy            = .ReloadIgnoringLocalAndRemoteCacheData
		sessionConfiguration.timeoutIntervalForRequest     = requestTimeout
    sessionConfiguration.timeoutIntervalForResource    = requestTimeout
    
		return sessionConfiguration
		
	}()
	
  /// Private initalizer
	private init() {
    
    operationQueue = NSOperationQueue()
    operationQueue.underlyingQueue = queue
    operationQueue.qualityOfService = .UserInitiated
    
		session = NSURLSession(configuration: sessionConfiguration, delegate: .None, delegateQueue: operationQueue)
    
	}
  
  /// Responsible for creating and managing request
  internal let session: NSURLSession
  
  /// Queue for `manager`s requests
  private let operationQueue: NSOperationQueue
  
  /// Queue for `manager`s requests
  internal let queue: dispatch_queue_t! = {
    return dispatch_queue_create(
      "com.gms-worldwide.manager-response-queue",
      DISPATCH_QUEUE_CONCURRENT)
  }()
  
}

// MARK: Static variables
internal extension HyberProvider {
	
  /// Default request timeot
	static let requestTimeout: Double = 15.0
	
  /// Shared instance of HyberProvider
	static let sharedInstance = HyberProvider()
	
  /// A dictionary of additional headers to send with requests in `sessionConfiguration`.
	static let defaultHTTPAdditionalHeaders: [String : String] = {
		return [
			"Authorization" : "app_key=\(Hyber.applicationKey)"
		]
	}()
	
  /// `NSURL` to Mobile Plaform (subscribers info) REST API
	static let mobilePlatformURL  = NSURL(
//    string: "http://10.12.8.1:8080/MobilePlatform/sdk_api/")!
    string: "https://mobile-test.gms-worldwide.com/MobilePlatform/sdk_api/")!
  
  /// `NSURL` to OTTBulk Plaform (delivery reports, message fetching) REST API
  static let ottBulkPlatformURL = NSURL(
//    string: "http://10.12.8.1:8080/OTTBulkPlatform/ott/sdk_api/")!
    string: "https://mobile-test.gms-worldwide.com/OTTBulkDr/ott/sdk_api/")!
}

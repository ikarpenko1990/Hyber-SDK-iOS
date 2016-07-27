//
//  hyberLog.swift
//  Hyber
//
//  Created by Vitalii Budnik on 12/10/15.
//  Copyright © 2015 Global Messages Services Worldwide. All rights reserved.
//

import Foundation
import UIKit
//import XCGLogger

/// `XCGLogger` instance for `Hyber.framework`
internal let hyberLog = Hyber.hyberLog

internal extension Hyber {
	/**
   `XCGLogger` instance for `Hyber.framework`
   */
	static let hyberLog: XCGLogger = {
		
		let url = NSFileManager.cachesDirectoryURL!.URLByAppendingPathComponent("hyberLog.txt")
		
    let log = XCGLogger(identifier: "Hyber.XCGLogger")
    
		log.xcodeColorsEnabled = true
		
    log.xcodeColors = Hyber.helper.settings.consoleLogColors
    
		return log
    
	}()
}

public extension Hyber {
	
	static func verify(log: Bool = true) -> Bool {
		
		self.hyberLog.debug("Verifying")
		
		var result: Bool = true
		
		if !authorized {
			result = false
			if log {
				self.hyberLog.error("User not authorized")
			}
		} else {
			if log {
				self.hyberLog.info("User authorized")
			}
		}
		
		if hyberDeviceId == 0 {
			result = false
			if log {
				self.hyberLog.error("No hyberDeviceId")
			}
		} else {
			if log {
				self.hyberLog.info("hyberDeviceId: \(hyberDeviceId)")
			}
		}
		
		if apnsToken == .None {
			result = false
			if log {
				self.hyberLog.error("No apnsToken")
			}
		} else {
			if log {
				self.hyberLog.info("apnsToken: \(apnsToken)")
			}
		}
		
		if firebaseMessagingToken == .None {
			result = false
			if log {
				self.hyberLog.error("No firebaseMessagingToken")
			}
		} else {
			if log {
				self.hyberLog.info("firebaseMessagingToken: \(firebaseMessagingToken)")
			}
		}
		
		return result
	}
}

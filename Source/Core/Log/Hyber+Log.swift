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
		
    let log = XCGLogger(identifier: "com.gms-worldwide.Hyber.logger")
    
		log.setup(
      .Verbose,
      showLogIdentifier: true,
      showFunctionName: true,
      showThreadName: true,
      showLogLevel: true,
      showFileNames: true,
      showLineNumbers: true,
      showDate: true,
      writeToFile: url,
      fileLogLevel: .Debug)
		
    log.xcodeColorsEnabled = true
		
    log.xcodeColors = [
			.Verbose: .lightGrey,
			.Debug: .darkGrey,
			.Info: .darkGreen,
      .Warning: XCGLogger.XcodeColor(fg: UIColor.orangeColor()),
			.Error: XCGLogger.XcodeColor(fg: UIColor.redColor()),
      .Severe: XCGLogger.XcodeColor(fg: UIColor.whiteColor(), bg: UIColor.redColor())
		]
    
		return log
    
	}()
	
}

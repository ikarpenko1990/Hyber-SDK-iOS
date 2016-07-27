//
//  XCGLogger.swift
//  XCGLogger: https://github.com/DaveWoodCom/XCGLogger
//
//  Created by Dave Wood on 2014-06-06.
//  Copyright (c) 2014 Dave Wood, Cerebral Gardens.
//  Some rights reserved: https://github.com/DaveWoodCom/XCGLogger/blob/master/LICENSE.txt
//

/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Dave Wood, Cerebral Gardens http://www.cerebralgardens.com/
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation
#if os(OSX)
  import AppKit
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
#endif

// swiftlint:disable

// MARK: - Enums
public enum HyberXCGLoggerLogLevel: Int, Comparable, CustomStringConvertible {
	case Verbose
	case Debug
	case Info
	case Warning
	case Error
	case Severe
	case None
	
	public var description: String {
		switch self {
		case .Verbose:
			return "Verbose"
		case .Debug:
			return "Debug"
		case .Info:
			return "Info"
		case .Warning:
			return "Warning"
		case .Error:
			return "Error"
		case .Severe:
			return "Severe"
		case .None:
			return "None"
		}
	}
}

// MARK: - XCGLogDetails
// - Data structure to hold all info about a log message, passed to log destination classes
internal struct XCGLogDetails {
  var logLevel: HyberXCGLoggerLogLevel
  var date: NSDate
  var logMessage: String
  var functionName: String
  var fileName: String
  var lineNumber: Int
  
  init(logLevel: HyberXCGLoggerLogLevel, date: NSDate, logMessage: String, functionName: String, fileName: String, lineNumber: Int) {
    self.logLevel = logLevel
    self.date = date
    self.logMessage = logMessage
    self.functionName = functionName
    self.fileName = fileName
    self.lineNumber = lineNumber
  }
}

// MARK: - XCGLogDestinationProtocol
// - Protocol for output classes to conform to
internal protocol XCGLogDestinationProtocol: CustomDebugStringConvertible {
  var owner: XCGLogger {get set}
  var identifier: String {get set}
  var outputLogLevel: HyberXCGLoggerLogLevel {get set}
  
  func processLogDetails(logDetails: XCGLogDetails)
  func processInternalLogDetails(logDetails: XCGLogDetails) // Same as processLogDetails but should omit function/file/line info
  func isEnabledForLogLevel(logLevel: HyberXCGLoggerLogLevel) -> Bool
}

// MARK: - XCGBaseLogDestination
// - A base class log destination that doesn't actually output the log anywhere and is intented to be subclassed
internal class XCGBaseLogDestination: XCGLogDestinationProtocol, CustomDebugStringConvertible {
  // MARK: - Properties
  var owner: XCGLogger
  var identifier: String
  var outputLogLevel: HyberXCGLoggerLogLevel = .Debug
  
  var showLogIdentifier: Bool = false
  var showFunctionName: Bool = true
  var showThreadName: Bool = false
  var showFileName: Bool = true
  var showLineNumber: Bool = true
  var showLogLevel: Bool = true
  var showDate: Bool = true
  
  // MARK: - CustomDebugStringConvertible
  var debugDescription: String {
    get {
      return "\(extractClassName(self)): \(identifier) - LogLevel: \(outputLogLevel) showLogIdentifier: \(showLogIdentifier) showFunctionName: \(showFunctionName) showThreadName: \(showThreadName) showLogLevel: \(showLogLevel) showFileName: \(showFileName) showLineNumber: \(showLineNumber) showDate: \(showDate)"
    }
  }
  
  // MARK: - Life Cycle
  init(owner: XCGLogger, identifier: String = "") {
    self.owner = owner
    self.identifier = identifier
  }
  
  // MARK: - Methods to Process Log Details
  func processLogDetails(logDetails: XCGLogDetails) {
    var extendedDetails: String = ""
    
    if showDate {
      var formattedDate: String = logDetails.date.description
      if let dateFormatter = owner.dateFormatter {
        formattedDate = dateFormatter.stringFromDate(logDetails.date)
      }
      
      extendedDetails += "\(formattedDate) "
    }
    
    if showLogLevel {
      extendedDetails += "[\(logDetails.logLevel)] "
    }
    
    if showLogIdentifier {
      extendedDetails += "[\(owner.identifier)] "
    }
    
    if showThreadName {
      if NSThread.isMainThread() {
        extendedDetails += "[main] "
      }
      else {
        if let threadName = NSThread.currentThread().name where !threadName.isEmpty {
          extendedDetails += "[" + threadName + "] "
        }
        else if let queueName = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)) where !queueName.isEmpty {
          extendedDetails += "[" + queueName + "] "
        }
        else {
          extendedDetails += "[" + String(format:"%p", NSThread.currentThread()) + "] "
        }
      }
    }
    
    if showFileName {
      extendedDetails += "[" + (logDetails.fileName as NSString).lastPathComponent + (showLineNumber ? ":" + String(logDetails.lineNumber) : "") + "] "
    }
    else if showLineNumber {
      extendedDetails += "[" + String(logDetails.lineNumber) + "] "
    }
    
    if showFunctionName {
      extendedDetails += "\(logDetails.functionName) "
    }
    
    output(logDetails, text: "\(extendedDetails)> \(logDetails.logMessage)")
  }
  
  func processInternalLogDetails(logDetails: XCGLogDetails) {
    var extendedDetails: String = ""
    
    if showDate {
      var formattedDate: String = logDetails.date.description
      if let dateFormatter = owner.dateFormatter {
        formattedDate = dateFormatter.stringFromDate(logDetails.date)
      }
      
      extendedDetails += "\(formattedDate) "
    }
    
    if showLogLevel {
      extendedDetails += "[\(logDetails.logLevel)] "
    }
    
    if showLogIdentifier {
      extendedDetails += "[\(owner.identifier)] "
    }
    
    output(logDetails, text: "\(extendedDetails)> \(logDetails.logMessage)")
  }
  
  // MARK: - Misc methods
  func isEnabledForLogLevel (logLevel: HyberXCGLoggerLogLevel) -> Bool {
    return logLevel >= self.outputLogLevel
  }
  
  // MARK: - Methods that must be overriden in subclasses
  func output(logDetails: XCGLogDetails, text: String) {
    // Do something with the text in an overridden version of this method
    precondition(false, "Must override this")
  }
}

// MARK: - XCGConsoleLogDestination
// - A standard log destination that outputs log details to the console
internal class XCGConsoleLogDestination: XCGBaseLogDestination {
  // MARK: - Properties
  var logQueue: dispatch_queue_t? = nil
  var xcodeColors: [HyberXCGLoggerLogLevel: XCGLogger.XcodeColor]? = nil
  
  // MARK: - Misc Methods
  override func output(logDetails: XCGLogDetails, text: String) {
    
    let outputClosure = {
      let adjustedText: String
      if let xcodeColor = (self.xcodeColors ?? self.owner.xcodeColors)[logDetails.logLevel] where self.owner.xcodeColorsEnabled {
        adjustedText = "\(xcodeColor.format())\(text)\(XCGLogger.XcodeColor.reset)"
      }
      else {
        adjustedText = text
      }
			
      NSLog("%@", adjustedText)
			
    }
    
    if let logQueue = logQueue {
      dispatch_async(logQueue, outputClosure)
    }
    else {
      outputClosure()
    }
  }
}

// MARK: - XCGNSLogDestination
// - A standard log destination that outputs log details to the console using NSLog instead of println
private class XCGNSLogDestination: XCGBaseLogDestination {
  // MARK: - Properties
  var logQueue: dispatch_queue_t? = nil
  var xcodeColors: [HyberXCGLoggerLogLevel: XCGLogger.XcodeColor]? = nil
  
  override var showDate: Bool {
    get {
      return false
    }
    set {
      // ignored, NSLog adds the date, so we always want showDate to be false in this subclass
    }
  }
  
  // MARK: - Misc Methods
  override func output(logDetails: XCGLogDetails, text: String) {
    
    let outputClosure = {
      let adjustedText: String
      if let xcodeColor = (self.xcodeColors ?? self.owner.xcodeColors)[logDetails.logLevel] where self.owner.xcodeColorsEnabled {
        adjustedText = "\(xcodeColor.format())\(text)\(XCGLogger.XcodeColor.reset)"
      }
      else {
        adjustedText = text
      }
      
      NSLog("%@", adjustedText)
    }
    
    if let logQueue = logQueue {
      dispatch_async(logQueue, outputClosure)
    }
    else {
      outputClosure()
    }
  }
}

// MARK: - XCGFileLogDestination
// - A standard log destination that outputs log details to a file
internal class XCGFileLogDestination: XCGBaseLogDestination {
  // MARK: - Properties
  var logQueue: dispatch_queue_t? = nil
  private var writeToFileURL: NSURL? = nil {
    didSet {
      openFile()
    }
  }
  private var logFileHandle: NSFileHandle? = nil
  
  // MARK: - Life Cycle
  init(owner: XCGLogger, writeToFile: AnyObject, identifier: String = "") {
    super.init(owner: owner, identifier: identifier)
    
    if writeToFile is NSString {
      writeToFileURL = NSURL.fileURLWithPath(writeToFile as! String)
    }
    else if writeToFile is NSURL {
      writeToFileURL = writeToFile as? NSURL
    }
    else {
      writeToFileURL = nil
    }
    
    openFile()
  }
  
  deinit {
    // close file stream if open
    closeFile()
  }
  
  // MARK: - File Handling Methods
  private func openFile() {
    if logFileHandle != nil {
      closeFile()
    }
    
    if let writeToFileURL = writeToFileURL,
      let path = writeToFileURL.path {
      
      NSFileManager.defaultManager().createFileAtPath(path, contents: nil, attributes: nil)
      do {
        logFileHandle = try NSFileHandle(forWritingToURL: writeToFileURL)
      }
      catch let error as NSError {
        owner._logln("Attempt to open log file for writing failed: \(error.localizedDescription)", logLevel: .Error)
        logFileHandle = nil
        return
      }
      
      owner.logAppDetails(self)
      
      let logDetails = XCGLogDetails(logLevel: .Info, date: NSDate(), logMessage: "XCGLogger writing to log to: \(writeToFileURL)", functionName: "", fileName: "", lineNumber: 0)
      owner._logln(logDetails.logMessage, logLevel: logDetails.logLevel)
      processInternalLogDetails(logDetails)
    }
  }
  
  private func closeFile() {
    logFileHandle?.closeFile()
    logFileHandle = nil
  }
  
  // MARK: - Misc Methods
  override func output(logDetails: XCGLogDetails, text: String) {
    
    let outputClosure = {
      if let encodedData = "\(text)\n".dataUsingEncoding(NSUTF8StringEncoding) {
        self.logFileHandle?.writeData(encodedData)
      }
    }
    
    if let logQueue = logQueue {
      dispatch_async(logQueue, outputClosure)
    }
    else {
      outputClosure()
    }
  }
}

// MARK: - XCGLogger
// - The main logging class
internal class XCGLogger: CustomDebugStringConvertible {
  // MARK: - Constants
  internal struct Constants {
    static let defaultInstanceIdentifier = "com.cerebralgardens.xcglogger.defaultInstance"
    static let baseConsoleLogDestinationIdentifier = "com.cerebralgardens.xcglogger.logdestination.console"
    static let nslogDestinationIdentifier = "com.cerebralgardens.xcglogger.logdestination.console.nslog"
    static let baseFileLogDestinationIdentifier = "com.cerebralgardens.xcglogger.logdestination.file"
    static let logQueueIdentifier = "com.cerebralgardens.xcglogger.queue"
    static let nsdataFormatterCacheIdentifier = "com.cerebralgardens.xcglogger.nsdataFormatterCache"
    static let versionString = "3.3"
  }
  private typealias constants = Constants // Preserve backwards compatibility: Constants should be capitalized since it's a type
  
  struct XcodeColor {
    static let escape = "\u{001b}["
    static let resetFg = "\u{001b}[fg;"
    static let resetBg = "\u{001b}[bg;"
    static let reset = "\u{001b}[;"
    
    var fg: (Int, Int, Int)? = nil
    var bg: (Int, Int, Int)? = nil
    
    func format() -> String {
      guard fg != nil || bg != nil else {
        // neither set, return reset value
        return XcodeColor.reset
      }
      
      var format: String = ""
      
      if let fg = fg {
        format += "\(XcodeColor.escape)fg\(fg.0),\(fg.1),\(fg.2);"
      }
      else {
        format += XcodeColor.resetFg
      }
      
      if let bg = bg {
        format += "\(XcodeColor.escape)bg\(bg.0),\(bg.1),\(bg.2);"
      }
      else {
        format += XcodeColor.resetBg
      }
      
      return format
    }
    
    init(fg: (Int, Int, Int)? = nil, bg: (Int, Int, Int)? = nil) {
      self.fg = fg
      self.bg = bg
    }
    
    #if os(OSX)
    init(fg: NSColor, bg: NSColor? = nil) {
      if let fgColorSpaceCorrected = fg.colorUsingColorSpaceName(NSCalibratedRGBColorSpace) {
        self.fg = (Int(fgColorSpaceCorrected.redComponent * 255), Int(fgColorSpaceCorrected.greenComponent * 255), Int(fgColorSpaceCorrected.blueComponent * 255))
      }
      else {
        self.fg = nil
      }
      
      if let bg = bg,
        let bgColorSpaceCorrected = bg.colorUsingColorSpaceName(NSCalibratedRGBColorSpace) {
        
        self.bg = (Int(bgColorSpaceCorrected.redComponent * 255), Int(bgColorSpaceCorrected.greenComponent * 255), Int(bgColorSpaceCorrected.blueComponent * 255))
      }
      else {
        self.bg = nil
      }
    }
    #elseif os(iOS) || os(tvOS) || os(watchOS)
    init(fg: UIColor, bg: UIColor? = nil) {
    var redComponent: CGFloat = 0
    var greenComponent: CGFloat = 0
    var blueComponent: CGFloat = 0
    var alphaComponent: CGFloat = 0
    
    fg.getRed(&redComponent, green: &greenComponent, blue: &blueComponent, alpha:&alphaComponent)
    self.fg = (Int(redComponent * 255), Int(greenComponent * 255), Int(blueComponent * 255))
    if let bg = bg {
    bg.getRed(&redComponent, green: &greenComponent, blue: &blueComponent, alpha:&alphaComponent)
    self.bg = (Int(redComponent * 255), Int(greenComponent * 255), Int(blueComponent * 255))
    }
    else {
    self.bg = nil
    }
    }
    #endif
    
    static let red: XcodeColor = {
      return XcodeColor(fg: (255, 0, 0))
    }()
    
    static let green: XcodeColor = {
      return XcodeColor(fg: (0, 255, 0))
    }()
    
    static let blue: XcodeColor = {
      return XcodeColor(fg: (0, 0, 255))
    }()
    
    static let black: XcodeColor = {
      return XcodeColor(fg: (0, 0, 0))
    }()
    
    static let white: XcodeColor = {
      return XcodeColor(fg: (255, 255, 255))
    }()
    
    static let lightGrey: XcodeColor = {
      return XcodeColor(fg: (211, 211, 211))
    }()
    
    static let darkGrey: XcodeColor = {
      return XcodeColor(fg: (169, 169, 169))
    }()
    
    static let orange: XcodeColor = {
      return XcodeColor(fg: (255, 165, 0))
    }()
    
    static let whiteOnRed: XcodeColor = {
      return XcodeColor(fg: (255, 255, 255), bg: (255, 0, 0))
    }()
    
    static let darkGreen: XcodeColor = {
      return XcodeColor(fg: (0, 128, 0))
    }()
  }
  
  // MARK: - Properties (Options)
  var identifier: String = ""
  var outputLogLevel: HyberXCGLoggerLogLevel = .Debug {
    didSet {
      for index in 0 ..< logDestinations.count {
        logDestinations[index].outputLogLevel = outputLogLevel
      }
    }
  }
  
  var xcodeColorsEnabled: Bool = false
  var xcodeColors: [HyberXCGLoggerLogLevel: XCGLogger.XcodeColor] = [
    .Verbose: .lightGrey,
    .Debug: .darkGrey,
    .Info: .blue,
    .Warning: .orange,
    .Error: .red,
    .Severe: .whiteOnRed
  ]
  
  // MARK: - Properties
  class var logQueue: dispatch_queue_t {
    struct Statics {
      static var logQueue = dispatch_queue_create(XCGLogger.Constants.logQueueIdentifier, nil)
    }
    
    return Statics.logQueue
  }
  
  private var _dateFormatter: NSDateFormatter? = nil
  var dateFormatter: NSDateFormatter? {
    get {
      if _dateFormatter != nil {
        return _dateFormatter
      }
      
      let defaultDateFormatter = NSDateFormatter()
      defaultDateFormatter.locale = NSLocale.currentLocale()
      defaultDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
      _dateFormatter = defaultDateFormatter
      
      return _dateFormatter
    }
    set {
      _dateFormatter = newValue
    }
  }
  
  private var logDestinations: Array<XCGLogDestinationProtocol> = []
  
  // MARK: - Life Cycle
  init(identifier: String = "", includeDefaultDestinations: Bool = true) {
    self.identifier = identifier
    
    // Check if XcodeColors is installed and enabled
    if let xcodeColors = NSProcessInfo.processInfo().environment["XcodeColors"] {
      xcodeColorsEnabled = xcodeColors == "YES"
    }
    
    if includeDefaultDestinations {
      // Setup a standard console log destination
      addLogDestination(XCGConsoleLogDestination(owner: self, identifier: XCGLogger.Constants.baseConsoleLogDestinationIdentifier))
    }
  }
  
  // MARK: - Default instance
  class func defaultInstance() -> XCGLogger {
    struct Statics {
      static let instance: XCGLogger = XCGLogger(identifier: XCGLogger.Constants.defaultInstanceIdentifier)
    }
    
    return Statics.instance
  }
  
  // MARK: - Setup methods
  class func setup(logLevel: HyberXCGLoggerLogLevel = .Debug, showLogIdentifier: Bool = false, showFunctionName: Bool = true, showThreadName: Bool = false, showLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true, showDate: Bool = true, writeToFile: AnyObject? = nil, fileLogLevel: HyberXCGLoggerLogLevel? = nil) {
    defaultInstance().setup(logLevel, showLogIdentifier: showLogIdentifier, showFunctionName: showFunctionName, showThreadName: showThreadName, showLogLevel: showLogLevel, showFileNames: showFileNames, showLineNumbers: showLineNumbers, showDate: showDate, writeToFile: writeToFile)
  }
  
  func setup(logLevel: HyberXCGLoggerLogLevel = .Debug, showLogIdentifier: Bool = false, showFunctionName: Bool = true, showThreadName: Bool = false, showLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true, showDate: Bool = true, writeToFile: AnyObject? = nil, fileLogLevel: HyberXCGLoggerLogLevel? = nil) {
    outputLogLevel = logLevel;
    
    if let standardConsoleLogDestination = logDestination(XCGLogger.Constants.baseConsoleLogDestinationIdentifier) as? XCGConsoleLogDestination {
      standardConsoleLogDestination.showLogIdentifier = showLogIdentifier
      standardConsoleLogDestination.showFunctionName = showFunctionName
      standardConsoleLogDestination.showThreadName = showThreadName
      standardConsoleLogDestination.showLogLevel = showLogLevel
      standardConsoleLogDestination.showFileName = showFileNames
      standardConsoleLogDestination.showLineNumber = showLineNumbers
      standardConsoleLogDestination.showDate = showDate
      standardConsoleLogDestination.outputLogLevel = logLevel
    }
    
    logAppDetails()
    
    if let writeToFile: AnyObject = writeToFile {
      // We've been passed a file to use for logging, set up a file logger
      let standardFileLogDestination: XCGFileLogDestination = XCGFileLogDestination(owner: self, writeToFile: writeToFile, identifier: XCGLogger.Constants.baseFileLogDestinationIdentifier)
      
      standardFileLogDestination.showLogIdentifier = showLogIdentifier
      standardFileLogDestination.showFunctionName = showFunctionName
      standardFileLogDestination.showThreadName = showThreadName
      standardFileLogDestination.showLogLevel = showLogLevel
      standardFileLogDestination.showFileName = showFileNames
      standardFileLogDestination.showLineNumber = showLineNumbers
      standardFileLogDestination.showDate = showDate
      standardFileLogDestination.outputLogLevel = fileLogLevel ?? logLevel
      
      addLogDestination(standardFileLogDestination)
    }
  }
  
  // MARK: - Logging methods
  class func logln(@autoclosure closure: () -> String?, logLevel: HyberXCGLoggerLogLevel = .Debug, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.defaultInstance().logln(logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  class func logln(logLevel: HyberXCGLoggerLogLevel = .Debug, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, @noescape closure: () -> String?) {
    self.defaultInstance().logln(logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  func logln(@autoclosure closure: () -> String?, logLevel: HyberXCGLoggerLogLevel = .Debug, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logln(logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  func logln(logLevel: HyberXCGLoggerLogLevel = .Debug, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, @noescape closure: () -> String?) {
    var logDetails: XCGLogDetails? = nil
    for logDestination in self.logDestinations {
      if (logDestination.isEnabledForLogLevel(logLevel)) {
        if logDetails == nil {
          if let logMessage = closure() {
            logDetails = XCGLogDetails(logLevel: logLevel, date: NSDate(), logMessage: logMessage, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
          }
          else {
            break
          }
        }
        
        logDestination.processLogDetails(logDetails!)
      }
    }
  }
  
  class func exec(logLevel: HyberXCGLoggerLogLevel = .Debug, closure: () -> () = {}) {
    self.defaultInstance().exec(logLevel, closure: closure)
  }
  
  func exec(logLevel: HyberXCGLoggerLogLevel = .Debug, closure: () -> () = {}) {
    if (!isEnabledForLogLevel(logLevel)) {
      return
    }
    
    closure()
  }
  
  internal func logAppDetails(selectedLogDestination: XCGLogDestinationProtocol? = nil) {
    let date = NSDate()
    
    var buildString = ""
    if let infoDictionary = NSBundle.mainBundle().infoDictionary {
      if let CFBundleShortVersionString = infoDictionary["CFBundleShortVersionString"] as? String {
        buildString = "Version: \(CFBundleShortVersionString) "
      }
      if let CFBundleVersion = infoDictionary["CFBundleVersion"] as? String {
        buildString += "Build: \(CFBundleVersion) "
      }
    }
    
    let processInfo: NSProcessInfo = NSProcessInfo.processInfo()
    let XCGLoggerVersionNumber = XCGLogger.Constants.versionString
    
    let logDetails: Array<XCGLogDetails> = [XCGLogDetails(logLevel: .Info, date: date, logMessage: "\(processInfo.processName) \(buildString)PID: \(processInfo.processIdentifier)", functionName: "", fileName: "", lineNumber: 0),
                                            XCGLogDetails(logLevel: .Info, date: date, logMessage: "XCGLogger Version: \(XCGLoggerVersionNumber) - LogLevel: \(outputLogLevel)", functionName: "", fileName: "", lineNumber: 0)]
    
    for logDestination in (selectedLogDestination != nil ? [selectedLogDestination!] : logDestinations) {
      for logDetail in logDetails {
        if !logDestination.isEnabledForLogLevel(.Info) {
          continue;
        }
        
        logDestination.processInternalLogDetails(logDetail)
      }
    }
  }
  
  // MARK: - Convenience logging methods
  // MARK: * Verbose
  class func verbose(@autoclosure closure: () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.defaultInstance().logln(.Verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  class func verbose(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, @noescape closure: () -> String?) {
    self.defaultInstance().logln(.Verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  func verbose(@autoclosure closure: () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logln(.Verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  func verbose(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, @noescape closure: () -> String?) {
    self.logln(.Verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  // MARK: * Debug
  class func debug(@autoclosure closure: () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.defaultInstance().logln(.Debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  class func debug(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, @noescape closure: () -> String?) {
    self.defaultInstance().logln(.Debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  func debug(@autoclosure closure: () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logln(.Debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  func debug(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, @noescape closure: () -> String?) {
    self.logln(.Debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  // MARK: * Info
  class func info(@autoclosure closure: () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.defaultInstance().logln(.Info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  class func info(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, @noescape closure: () -> String?) {
    self.defaultInstance().logln(.Info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  func info(@autoclosure closure: () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logln(.Info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  func info(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, @noescape closure: () -> String?) {
    self.logln(.Info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  // MARK: * Warning
  class func warning(@autoclosure closure: () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.defaultInstance().logln(.Warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  class func warning(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, @noescape closure: () -> String?) {
    self.defaultInstance().logln(.Warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  func warning(@autoclosure closure: () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logln(.Warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  func warning(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, @noescape closure: () -> String?) {
    self.logln(.Warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  // MARK: * Error
  class func error(@autoclosure closure: () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.defaultInstance().logln(.Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  class func error(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, @noescape closure: () -> String?) {
    self.defaultInstance().logln(.Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  func error(@autoclosure closure: () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logln(.Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  func error(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, @noescape closure: () -> String?) {
    self.logln(.Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  // MARK: * Severe
  class func severe(@autoclosure closure: () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.defaultInstance().logln(.Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  class func severe(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, @noescape closure: () -> String?) {
    self.defaultInstance().logln(.Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  func severe(@autoclosure closure: () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logln(.Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  func severe(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, @noescape closure: () -> String?) {
    self.logln(.Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
  }
  
  // MARK: - Exec Methods
  // MARK: * Verbose
  class func verboseExec(closure: () -> () = {}) {
    self.defaultInstance().exec(HyberXCGLoggerLogLevel.Verbose, closure: closure)
  }
  
  func verboseExec(closure: () -> () = {}) {
    self.exec(HyberXCGLoggerLogLevel.Verbose, closure: closure)
  }
  
  // MARK: * Debug
  class func debugExec(closure: () -> () = {}) {
    self.defaultInstance().exec(HyberXCGLoggerLogLevel.Debug, closure: closure)
  }
  
  func debugExec(closure: () -> () = {}) {
    self.exec(HyberXCGLoggerLogLevel.Debug, closure: closure)
  }
  
  // MARK: * Info
  class func infoExec(closure: () -> () = {}) {
    self.defaultInstance().exec(HyberXCGLoggerLogLevel.Info, closure: closure)
  }
  
  func infoExec(closure: () -> () = {}) {
    self.exec(HyberXCGLoggerLogLevel.Info, closure: closure)
  }
  
  // MARK: * Warning
  class func warningExec(closure: () -> () = {}) {
    self.defaultInstance().exec(HyberXCGLoggerLogLevel.Warning, closure: closure)
  }
  
  func warningExec(closure: () -> () = {}) {
    self.exec(HyberXCGLoggerLogLevel.Warning, closure: closure)
  }
  
  // MARK: * Error
  class func errorExec(closure: () -> () = {}) {
    self.defaultInstance().exec(HyberXCGLoggerLogLevel.Error, closure: closure)
  }
  
  func errorExec(closure: () -> () = {}) {
    self.exec(HyberXCGLoggerLogLevel.Error, closure: closure)
  }
  
  // MARK: * Severe
  class func severeExec(closure: () -> () = {}) {
    self.defaultInstance().exec(HyberXCGLoggerLogLevel.Severe, closure: closure)
  }
  
  func severeExec(closure: () -> () = {}) {
    self.exec(HyberXCGLoggerLogLevel.Severe, closure: closure)
  }
  
  // MARK: - Misc methods
  func isEnabledForLogLevel (logLevel: HyberXCGLoggerLogLevel) -> Bool {
    return logLevel >= self.outputLogLevel
  }
  
  private func logDestination(identifier: String) -> XCGLogDestinationProtocol? {
    for logDestination in logDestinations {
      if logDestination.identifier == identifier {
        return logDestination
      }
    }
    
    return nil
  }
  
  internal func addLogDestination(logDestination: XCGLogDestinationProtocol) -> Bool {
    let existingLogDestination: XCGLogDestinationProtocol? = self.logDestination(logDestination.identifier)
    if existingLogDestination != nil {
      return false
    }
    
    logDestinations.append(logDestination)
    return true
  }
  
  private func removeLogDestination(logDestination: XCGLogDestinationProtocol) {
    removeLogDestination(logDestination.identifier)
  }
  
  func removeLogDestination(identifier: String) {
    logDestinations = logDestinations.filter({$0.identifier != identifier})
  }
  
  // MARK: - Private methods
  private func _logln(logMessage: String, logLevel: HyberXCGLoggerLogLevel = .Debug) {
    
    var logDetails: XCGLogDetails? = nil
    for logDestination in self.logDestinations {
      if (logDestination.isEnabledForLogLevel(logLevel)) {
        if logDetails == nil {
          logDetails = XCGLogDetails(logLevel: logLevel, date: NSDate(), logMessage: logMessage, functionName: "", fileName: "", lineNumber: 0)
        }
        
        logDestination.processInternalLogDetails(logDetails!)
      }
    }
  }
  
  // MARK: - DebugPrintable
  var debugDescription: String {
    get {
      var description: String = "\(extractClassName(self)): \(identifier) - logDestinations: \r"
      for logDestination in logDestinations {
        description += "\t \(logDestination.debugDescription)\r"
      }
      
      return description
    }
  }
}

// Implement Comparable for HyberXCGLoggerLogLevel
public func < (lhs:HyberXCGLoggerLogLevel, rhs:HyberXCGLoggerLogLevel) -> Bool {
  return lhs.rawValue < rhs.rawValue
}

private func extractClassName(someObject: Any) -> String {
  return (someObject is Any.Type) ? "\(someObject)" : "\(someObject.dynamicType)"
}

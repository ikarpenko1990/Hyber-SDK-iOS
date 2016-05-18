//
//  NSFileManager+DirectoryURLs.swift
//  Hyber
//
//  Created by Vitalii Budnik on 12/10/15.
//  Copyright © 2015 Global Message Services Worldwide. All rights reserved.
//

import Foundation

/**
 Adds `static lazy var`iables for `NSSearchPathDirectory.CachesDirectory` 
 and `NSSearchPathDirectory.LibraryDirectory`
 */
internal extension NSFileManager {
	
  /**
   An `NSURL` for the Caches directory in the user’s home directory, 
   `nil` if directory is not found. (read-only)
   */
	@nonobjc static var cachesDirectoryURL: NSURL? = {
		
		let directoriesURLS = NSFileManager.defaultManager()
      .URLsForDirectory(.CachesDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
		
		return directoriesURLS.first
		
	}()
	
  /**
   An `NSURL` for the Library directory in the user’s home directory, 
   `nil` if directory is not found. (read-only)
   */
	@nonobjc static var libraryDirectoryURL: NSURL? = {
		
		let directoriesURLS = NSFileManager.defaultManager()
      .URLsForDirectory(.LibraryDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
		
		return directoriesURLS.first
		
	}()
  
}

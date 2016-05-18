//
//  Hyber+Localization.swift
//  Hyber
//
//  Created by Vitalii Budnik on 3/28/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation

public extension Hyber {
  
  /// `Hyber.framework` bundle. (read-only)
  public private (set) static var bundle = NSBundle(forClass: Hyber.self)
  internal private (set) static var nonLocalizedBundle = NSBundle(forClass: Hyber.self)
  
  internal static var currentLocale: NSLocale = NSLocale(
    localeIdentifier: NSLocale.preferredLanguages().first!)
  
  /**
   Localizes `Hyber.bundle`
   
   - parameter language: New language `String`
   */
  static func localize(language: String) {
    
    if language == currentLocale.localeIdentifier {
      return
    }
    
    let localizedBudnle = localizedBundle(NSBundle(forClass: Hyber.self), language: language)
    
    Hyber.bundle = localizedBudnle
    
    currentLocale = NSLocale(localeIdentifier: language)
    
    NSNotificationCenter.defaultCenter().postNotificationName(
      HyberLocalizationDidChangeNotification,
      object: .None)
    
  }
  
  /**
   Returns localized `NSBundle`
   
   - parameter bundle: `NSBundle` to localize
   - parameter language: `String` with language name
   
   - returns: Localized `NSBundle`
   */
  internal static func localizedBundle(bundle: NSBundle, language: String) -> NSBundle {
    let localeComponents = NSLocale.componentsFromLocaleIdentifier(language)
    let languageCode = localeComponents[NSLocaleLanguageCode] ?? language
    
    /// list of possible .lproj folders names
    let lprojFolderPatterns: [String?] = [
      language, // en-GB.lproj
      language.stringByReplacingOccurrencesOfString("-", withString: "_"), // en_GB.lproj
      (languageCode != language) ? languageCode : nil, // en.lproj
      NSLocale(localeIdentifier: "en").displayNameForKey(NSLocaleIdentifier, value: language) // English.lproj
    ]
    
    /// Available folders in bundle
    let lprojFoldersPaths: [String] = lprojFolderPatterns.flatMap {
      if let folderName = $0,
        path = bundle.pathForResource(folderName, ofType: "lproj") {
        return path
      } else {
        return nil
      }
    }
    
    let localizedBundlePath = lprojFoldersPaths.first
    
    // Getting localized bundle
    let localizedBudnle: NSBundle
    if let
      localizedBundlePath = localizedBundlePath,
      newBundle = NSBundle(path: localizedBundlePath) // swiftlint:disable:this opening_brace
    {
      localizedBudnle = newBundle
      
    } else {
      return localizedBundle(bundle, language: "en")
      
    }
    
    return localizedBudnle
    
  }
  
}

 /// Hyber Localization Did Change Notification name
public let HyberLocalizationDidChangeNotification = //swiftlint:disable:this variable_name
"com.gms-worldwide.Hyber.LocalizationDidChangeNotification"

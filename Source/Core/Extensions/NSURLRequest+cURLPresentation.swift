//
//  NSURLRequest+cURLPresentation.swift
//  Hyber
//
//  Created by Vitalii Budnik on 3/30/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation

internal extension NSURLRequest {
  
  // swiftlint:disable cyclomatic_complexity
  // swiftlint:disable opening_brace
  // swiftlint:disable function_body_length
  
  /**
   Textual presentation for cURL command
   
   - parameter session: `NSURLSession` in which request (will be) started
   
   - returns: cURL command `String`
   */
  @nonobjc func cURLRepresentation(
    session: NSURLSession = HyberProvider.sharedInstance.session) -> String
  {
    return cURLRepresentation(session.configuration)
  }
  
  /**
   Textual presentation for cURL command
   
   - parameter configuration: `NSURLSessionConfiguration` with which request (will be) started
   
   - returns: cURL command `String`
   */
  @nonobjc func cURLRepresentation(
    configuration: NSURLSessionConfiguration) -> String
  {
    var components = ["$ curl -i"]
    
    guard let
      //        request = self.request,
      URL = URL,
      host = URL.host
      else {
        return "$ curl command could not be created"
    }
    
    if let HTTPMethod = HTTPMethod where HTTPMethod != "GET" {
      components.append("-X \(HTTPMethod)")
    }
    
    if let credentialStorage = configuration.URLCredentialStorage {
      let protectionSpace = NSURLProtectionSpace(
        host: host,
        port: URL.port?.integerValue ?? 0,
        protocol: URL.scheme,
        realm: host,
        authenticationMethod: NSURLAuthenticationMethodHTTPBasic
      )
      
      if let credentials = credentialStorage.credentialsForProtectionSpace(protectionSpace)?.values {
        for credential in credentials {
          components.append("-u \(credential.user!):\(credential.password!)")
        }
      }
    }
    
    if configuration.HTTPShouldSetCookies {
      if let
        cookieStorage = configuration.HTTPCookieStorage,
        cookies = cookieStorage.cookiesForURL(URL) where !cookies.isEmpty
      {
        let string = cookies.reduce("") { $0 + "\($1.name)=\($1.value ?? String());" }
        components.append("-b \"\(string.substringToIndex(string.endIndex.predecessor()))\"")
      }
    }
    
    if let headerFields = allHTTPHeaderFields {
      for (field, value) in headerFields {
        switch field {
        case "Cookie":
          continue
        default:
          components.append("-H \"\(field): \(value)\"")
        }
      }
    }
    
    if let additionalHeaders = configuration.HTTPAdditionalHeaders {
      for (field, value) in additionalHeaders {
        switch field {
        case "Cookie":
          continue
        default:
          components.append("-H \"\(field): \(value)\"")
        }
      }
    }
    
    if let
      HTTPBodyData = HTTPBody,
      HTTPBody = String(data: HTTPBodyData, encoding: NSUTF8StringEncoding)
    {
      let escapedBody = HTTPBody.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
      components.append("-d \"\(escapedBody)\"")
    }
    
    components.append("\"\(URL.absoluteString)\"")
    
    return components.joinWithSeparator(" \\\n\t")
  }
  
  // swiftlint:enable cyclomatic_complexity
  // swiftlint:enable opening_brace
  // swiftlint:enable function_body_length
  
}

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
    var components: [String] = ["$ curl -i"]
    
    guard let URL = URL else { return "$ curl command could not be created" }
    
    if let HTTPMethod = HTTPMethod where HTTPMethod != "GET" {
      components.append(String(format: "-X %@", HTTPMethod))
    }
    
    if let headerFields = allHTTPHeaderFields {
      headerFields.forEach { (field, value) in
        switch field {
        case "Cookie":
          return
        default:
          components.append(String(format: "-H \"%@: %@\"", field, value)    )
        }
      }
    }
    
    if let additionalHeaders = configuration.HTTPAdditionalHeaders {
      additionalHeaders.forEach { (field, value) in
        switch field {
        case "Cookie":
          return
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

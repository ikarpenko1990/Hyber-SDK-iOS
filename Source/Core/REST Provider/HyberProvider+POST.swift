//
//  HyberProvider+POST.swift
//  Hyber
//
//  Created by Vitalii Budnik on 12/15/15.
//
//

import Foundation

internal extension HyberProvider {
  /**
   List of available REST API providers
   */
  internal enum RESTProvider {
    /// Moblie platform
    case MobilePlatform
    /// OTTBulk platform
    case OTTPlatform
    
    /**
     Returns an `NSURL` for concrete provider type
     - Returns: An `NSURL` for concrete provider type
     */
    func URL() -> NSURL {
      switch self {
      case .MobilePlatform:
        return HyberProvider.mobilePlatformURL
      case .OTTPlatform:
        return HyberProvider.ottBulkPlatformURL
      }
    }
    
  }
  
  /**
   POSTs request to MobilePlatform to specifyed API URL string with parameters
   - Parameter urlString: The URL string relative to MobilePlatform URL
   - Parameter parameters: The parameters
   - Returns: The created `Request`
   */
  internal func POST(
    urlString: String,
    parameters: [String : AnyObject])
    -> NSURLSessionTask? // swiftlint:disable:this opening_brace
  {
    
    return POST(.MobilePlatform, urlString, parameters: parameters)
    
  }
  
  /**
   POSTs request to specifyed relative URL string of REST API provider with parameters
   - Parameter restProvider: The REST API provider
   - Parameter urlString: The URL string relative to REST API provider URL
   - Parameter parameters: The parameters
   - Returns: The created `Request`
   */
  internal func POST(
    restProvider: RESTProvider,
    urlString: String,
    parameters: [String : AnyObject])
    -> NSURLSessionTask? // swiftlint:disable:this opening_brace
  {
    
    return POST(NSURL(string: urlString, relativeToURL: restProvider.URL())!, parameters: parameters)
    
  }
  
  
  
  /**
   POSTs request to specifyed relative URL string of MobilePlatform REST API with parameters
   
   - Parameter urlString: The URL string relative to MobilePlatform URL
   - Parameter parameters: The parameters
   - Parameter checkStatus: `Bool` that indicates to check `"status"` flag in JSON response.
   Default: `true`
   - Parameter completionHandler: The code to be executed once the request has finished.
   
   - Returns: The created `Request`
   */
  internal func POST(
    urlString: String,
    parameters: [String : AnyObject]?,
    checkStatus: Bool = true,
    completionHandler completion: (HyberResult<[String : AnyObject]> -> Void)? = .None)
    -> NSURLSessionTask? // swiftlint:disable:this opening_brace
  {
    
    return POST(
      .MobilePlatform,
      urlString,
      parameters: parameters,
      checkStatus: checkStatus,
      completionHandler: completion)
    
  }
  
  
  /**
   POSTs request to specifyed relative URL string of REST API provider with parameters
   
   - Parameter restProvider: The REST API provider
   - Parameter urlString: The URL string relative to REST API provider URL
   - Parameter parameters: The parameters
   - Parameter checkStatus: `Bool` that indicates to check `"status"` flag in JSON response.
   Default: `true`
   - Parameter completionHandler: The code to be executed once the request has finished.
   
   - Returns: The created `Request`
   
   */
  internal func POST(
    restProvider: RESTProvider,
    _ urlString: String,
    parameters: [String : AnyObject]?,
    checkStatus: Bool = true,
    completionHandler completion: (HyberResult<[String : AnyObject]> -> Void)? = .None)
    -> NSURLSessionTask? // swiftlint:disable:this opening_brace
  {
    
    return POST(
      NSURL(string: urlString, relativeToURL: restProvider.URL())!,
      parameters: parameters,
      checkStatus: checkStatus,
      completionHandler: completion)
    
  }
  // swiftlint:enable line_length
  
  /**
   POSTs request to specifyed relative URL with parameters
   
   - Parameter url: The URL
   - Parameter parameters: The parameters
   - Parameter checkStatus: `Bool` that indicates to check `"status"` flag in JSON response.
   Default: `true`
   - Parameter completionHandler: The code to be executed once the request has finished.
   
   - Returns: The created `Request`
   */
  private func POST(
    url: NSURL,
    parameters: [String : AnyObject]?,
    checkStatus: Bool = true,
    completionHandler completion: (HyberResult<[String : AnyObject]> -> Void)? = .None)
    -> NSURLSessionTask? // swiftlint:disable:this opening_brace
  {
    
    guard let request: NSURLRequest = self.request(url, parameters: parameters).value(completion) else {
      return .None
    }
    
    hyberLog.verbose("POST.request: \(request.cURLRepresentation())")
    
    let dataTask = session.dataTaskWithRequest(request) { [weak self, request] (data, response, error) in
      
      guard let sSelf = self else { completion?(.Failure(HyberError.UnknownError)); return }
      
      var output = sSelf.dataTaskWithRequestResultDebugDescription(request, data, response) ?? []
      
      let serializedResult = sSelf.JSONdataTaskResult(data, response, error, checkStatus: checkStatus)
      guard let
        json = serializedResult.value(completion)
        else {
          output.append("")
          output.append(
            (serializedResult.error ?? HyberError.UnknownError).localizedDescription)
          
          hyberLog.error(output.joinWithSeparator("\n"))
          return
      }
      
      output.append("[JSON]: \(json.debugDescription)")
      output.append("")
      hyberLog.verbose(output.joinWithSeparator("\n"))
      
      completion?(.Success(json))
      
    }
    
    dataTask.resume()
    
    return dataTask
    
  }
  
  /**
   Returns `Array<String>` containing debug description lines of recieved `response data` of sended `request`
   
   - parameter request:  `NSURLRequest` sended to server.
   - parameter data:     The data returned by the server.
   - parameter response: A `NSHTTPURLResponse` that provides response metadata, such as
   HTTP headers and status code.
   
   - returns: `Array<String>` containing debug description lines
   */
  private func dataTaskWithRequestResultDebugDescription(
    request: NSURLRequest? = .None,
    _ data: NSData?,
    _ response: NSURLResponse?)
    -> [String] // swiftlint:disable:this opening_brace
  {
    var output: [String] = []
    output.append("POST.response")
    output.append("[Request]: \(request?.cURLRepresentation() ?? "nil")")
    output.append(response != nil ? "[Response]: \(response!.debugDescription)" : "[Response]: nil")
    output.append("[Data]: \(data?.length ?? 0) bytes")
    if let
      data = data,
      dataString = String(data: data, encoding: NSUTF8StringEncoding) //sfiftlint:disable:this opening_brace
    {
      output.append("[Data String]: \(dataString)")
    } else {
      output.append("[Data String]: nil")
    }
    return output
  }
  
  /**
   Serializes result of `NSURLSession.dataTaskWithRequest`
   
   - parameter data:        The data returned by the server.
   - parameter response:    A `NSHTTPURLResponse` that provides response metadata, such as
   HTTP headers and status code.
   - parameter error:       An error object that indicates why the request failed,
   or nil if the request was successful.
   - parameter checkStatus: `Bool` that indicates to check `"status"` flag in JSON response.
   Default: `true`
   
   - returns: `HyberResult` containing serialized JSON (`[String : AnyObject]]`)
   */
  private func JSONdataTaskResult(
    data: NSData?,
    _ response: NSURLResponse?,
    _ error: NSError?,
    checkStatus: Bool = true)
    -> HyberResult<[String : AnyObject]> // swiftlint:disable:this opening_brace
  {
    
    guard let data = data else {
      if let error = error {
        hyberLog.error(error.localizedDescription)
        return .Failure(.RequestError(.Error(error)))
      } else {
        hyberLog.error(HyberError.Request.UnknownError.localizedDescription)
        return .Failure(.RequestError(.UnknownError))
      }
    }
    
    let json: [String: AnyObject]
    do {
      let dataObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
      guard let serializedDataObject = dataObject as? [String: AnyObject] else {
        let error: HyberError = .ResultParsingError(.CantRepresentResultAsDictionary)
        hyberLog.error(error.localizedDescription)
        return .Failure(error)
      }
      json = serializedDataObject
    } catch {
      hyberLog.error((error as NSError).localizedDescription)
      return .Failure(.ResultParsingError(.JSONSerializationError(error as NSError)))
    }
    
    if checkStatus {
      
      guard let status = json["status"] as? Bool else {
        let error = HyberError.ResultParsingError(.NoStatus)
        hyberLog.error(error.localizedDescription)
        return .Failure(error)
      }
      
      if !status {
        let error = HyberError.ResultParsingError(.StatusIsFalse(json["response"] as? String))
        hyberLog.error(error.localizedDescription)
        return .Failure(error)
      }
      
    }
    
    return .Success(json)
    
  }
  
  /**
   Creates `NSURLRequest`
   
   - parameter URL:        The URL
   - parameter parameters: The parameters for `NSURLRequest`
   
   - returns: `HyberResult<NSURLRequest>`
   */
  private func request(
    URL: NSURL,
    parameters: [String : AnyObject]?)
    -> HyberResult<NSURLRequest> // swift:lint:disable:this opening_brace
  {
    let request = NSMutableURLRequest(URL: URL)
    request.HTTPMethod = "POST"
    
    guard let parameters = parameters else {
      return .Success(request)
    }
    
    do {
      let jsonData = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
      request.HTTPBody = jsonData
      
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
    } catch {
      hyberLog.error("\(error as NSError)")
      
      return .Failure(.RequestError(.ParametersSerializationError(error as NSError)))
    }
    
    return .Success(request)
  }
  
}

extension NSURLResponse {
  
}

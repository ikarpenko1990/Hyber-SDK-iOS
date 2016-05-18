// HyberResult.swift
//

import Foundation

/**
 Used to represent whether a request was successful or encountered an error.
 
 - Success: The request and all post processing operations were successful resulting in the 
 serialization of the provided associated value.
 - Failure: The request encountered an error resulting in a failure. The associated values are 
 the original data provided by the server as well as the error that caused the failure.
 */
public enum HyberResult<Value> {
  
  /// Success. Contains result of success operation of `Value` type
  case Success(Value)
  
  /// Failure. Contains a `HyberError` describing occurred error
  case Failure(HyberError)
  
  /// Returns `true` if the result is a success, `false` otherwise.
  public var isSuccess: Bool {
    switch self {
    case .Success:
      return true
    case .Failure:
      return false
    }
  }
  
  /// Returns `true` if the result is a failure, `false` otherwise.
  public var isFailure: Bool {
    return !isSuccess
  }
  
  /// Returns the associated value if the result is a success, `nil` otherwise.
  public var value: Value? {
    switch self {
    case .Success(let value):
      return value
    case .Failure:
      return nil
    }
  }
  
  /// Returns the associated error value if the result is a failure, `nil` otherwise.
  public var error: HyberError? {
    switch self {
    case .Success:
      return nil
    case .Failure(let error):
      return error
    }
  }
  
  /**
   Returns `Value` if `self` is `.Success`, otherwise calls `completion` closure and returns `nil`
   
   - parameter errorCompletionHandler: closure that takes `HyberResult` as a parameter
   
   - returns: `Value` if `self` is `.Success`, otherwise calls `completion` closure and returns `nil`
   */
  public func value<V>(
    errorCompletionHandler: ((HyberResult<V>) -> Void)?)
    -> Value? // swiftlint:disable:this opening_brace
  {
    
    guard let resultValue = value else {
      isFailure(errorCompletionHandler)
      return .None
    }
    
    return resultValue
    
  }
  
  /**
   Calls `completion` closure and returns `true` if `self` is `.Failure`, otherwise and returns `false`
   
   - parameter errorCompletionHandler: closure that takes `HyberResult` as a parameter
   
   - returns: `false` if `self` is `.Success`, otherwise calls `completion` closure and returns `true`
   */
  public func isFailure<V>(
    errorCompletionHandler: ((HyberResult<V>) -> Void)?)
    -> Bool // swiftlint:disable:this opening_brace
  {
    
    switch self {
    case .Failure(let error):
      hyberLog.error(error.localizedDescription)
      errorCompletionHandler?(.Failure(error))
      return true
    default:
      break
    }
    
    return false
    
  }
  
}

// MARK: - CustomStringConvertible

extension HyberResult: CustomStringConvertible {
  /// The textual representation used when written to an output stream, which includes whether the 
  /// result was a success or failure.
  public var description: String {
    switch self {
    case .Success:
      return "SUCCESS"
    case .Failure:
      return "FAILURE"
    }
  }
}

// MARK: - CustomDebugStringConvertible

extension HyberResult: CustomDebugStringConvertible {
  /// The debug textual representation used when written to an output stream, which includes whether 
  /// the result was a success or failure in addition to the value or error.
  public var debugDescription: String {
    switch self {
    case .Success(let value):
      return "SUCCESS: \(value)"
    case .Failure(let error):
      return "FAILURE: \(error)"
    }
  }
}

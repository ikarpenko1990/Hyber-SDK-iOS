//
//  RxAlamofireHelper.swift
//  Pods
//
//  Created by Taras on 11/4/16.
//
//

import Foundation
import Alamofire
import RxSwift

/// Default instance of unknown error
public let RxAlamofireUnknownError = NSError(domain: "RxAlamofireHyber", code: -1, userInfo: nil)



// MARK: Convenience functions

public func urlRequest(_ method: Alamofire.HTTPMethod,
                       _ url: URLConvertible,
                       parameters: [String: Any]? = nil,
                       encoding: ParameterEncoding = URLEncoding.default,
                       headers: [String: String]? = nil)
throws -> Foundation.URLRequest
{
    var mutableURLRequest = Foundation.URLRequest(url: try url.asURL())
    mutableURLRequest.httpMethod = method.rawValue

    if let headers = headers {
        for (headerField, headerValue) in headers {
            mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
        }
    }

    if let parameters = parameters {
        mutableURLRequest = try encoding.encode(mutableURLRequest, with: parameters)
    }

    return mutableURLRequest
}

// MARK: Request

public func request(_ method: Alamofire.HTTPMethod,
                    _ url: URLConvertible,
                    parameters: [String: Any]? = nil,
                    encoding: ParameterEncoding = URLEncoding.default,
                    headers: [String: String]? = nil)
    -> Observable<DataRequest>
{
    return SessionManager.default.rx.request(
                                             method,
                                             url,
                                             parameters: parameters,
                                             encoding: encoding,
                                             headers: headers
    )
}

// MARK: data

public func requestData(_ method: Alamofire.HTTPMethod,
                        _ url: URLConvertible,
                        parameters: [String: Any]? = nil,
                        encoding: ParameterEncoding = URLEncoding.default,
                        headers: [String: String]? = nil)
    -> Observable<(HTTPURLResponse, Data)>
{
    return SessionManager.default.rx.responseData(
                                                  method,
                                                  url,
                                                  parameters: parameters,
                                                  encoding: encoding,
                                                  headers: headers
    )
}


public func data(_ method: Alamofire.HTTPMethod,
                 _ url: URLConvertible,
                 parameters: [String: Any]? = nil,
                 encoding: ParameterEncoding = URLEncoding.default,
                 headers: [String: String]? = nil)
    -> Observable<Data>
{
    return SessionManager.default.rx.data(
                                          method,
                                          url,
                                          parameters: parameters,
                                          encoding: encoding,
                                          headers: headers
    )
}

// MARK: string

public func requestString(_ method: Alamofire.HTTPMethod,
                          _ url: URLConvertible,
                          parameters: [String: Any]? = nil,
                          encoding: ParameterEncoding = URLEncoding.default,
                          headers: [String: String]? = nil)
    -> Observable<(HTTPURLResponse, String)>
{
    return SessionManager.default.rx.responseString(
                                                    method,
                                                    url,
                                                    parameters: parameters,
                                                    encoding: encoding,
                                                    headers: headers
    )
}

public func string(_ method: Alamofire.HTTPMethod,
                   _ url: URLConvertible,
                   parameters: [String: Any]? = nil,
                   encoding: ParameterEncoding = URLEncoding.default,
                   headers: [String: String]? = nil)
    -> Observable<String>
{
    return SessionManager.default.rx.string(
                                            method,
                                            url,
                                            parameters: parameters,
                                            encoding: encoding,
                                            headers: headers
    )
}

// MARK: JSON

public func requestJSON(_ method: Alamofire.HTTPMethod,
                        _ url: URLConvertible,
                        parameters: [String: Any]? = nil,
                        encoding: ParameterEncoding = URLEncoding.default,
                        headers: [String: String]? = nil)
    -> Observable<(HTTPURLResponse, Any)>
{
    return SessionManager.default.rx.responseJSON(
                                                  method,
                                                  url,
                                                  parameters: parameters,
                                                  encoding: encoding,
                                                  headers: headers
    )
}

public func json(_ method: Alamofire.HTTPMethod,
                 _ url: URLConvertible,
                 parameters: [String: Any]? = nil,
                 encoding: ParameterEncoding = URLEncoding.default,
                 headers: [String: String]? = nil)
    -> Observable<Any>
{
    return SessionManager.default.rx.json(
                                          method,
                                          url,
                                          parameters: parameters,
                                          encoding: encoding,
                                          headers: headers
    )
}

// MARK: Upload
public func upload(_ file: URL, urlRequest: URLRequestConvertible) -> Observable<UploadRequest> {
    return SessionManager.default.rx.upload(file, urlRequest: urlRequest)
}

public func upload(_ data: Data, urlRequest: URLRequestConvertible) -> Observable<UploadRequest> {
    return SessionManager.default.rx.upload(data, urlRequest: urlRequest)
}

public func upload(_ stream: InputStream, urlRequest: URLRequestConvertible) -> Observable<UploadRequest> {
    return SessionManager.default.rx.upload(stream, urlRequest: urlRequest)
}

// MARK: Download

public func download(_ urlRequest: URLRequestConvertible,
                     to destination: @escaping DownloadRequest.DownloadFileDestination) -> Observable<DownloadRequest> {
    return SessionManager.default.rx.download(urlRequest, to: destination)
}

// MARK: Resume Data

public func download(resumeData: Data,
                     to destination: @escaping DownloadRequest.DownloadFileDestination) -> Observable<DownloadRequest> {
    return SessionManager.default.rx.download(resumeData: resumeData, to: destination)
}

// MARK: Manager - Extension of Manager
extension SessionManager: ReactiveCompatible {
}

protocol RxAlamofireRequest {

    func responseWith(completionHandler: @escaping (RxAlamofireResponse) -> Void)
    func resume()
    func cancel()
}

protocol RxAlamofireResponse {
    var error: Error? { get }
}

extension DefaultDataResponse: RxAlamofireResponse { }

extension DefaultDownloadResponse: RxAlamofireResponse { }

extension DataRequest: RxAlamofireRequest {
    func responseWith(completionHandler: @escaping (RxAlamofireResponse) -> Void) {
        response { (response) in
            completionHandler(response)
        }
    }
}

extension DownloadRequest: RxAlamofireRequest {
    func responseWith(completionHandler: @escaping (RxAlamofireResponse) -> Void) {
        response { (response) in
            completionHandler(response)
        }
    }
}


extension Reactive where Base: SessionManager {

    // MARK: Generic request convenience

    func request<R: RxAlamofireRequest>(_ createRequest: @escaping (SessionManager) throws -> R) -> Observable<R> {
        return Observable.create { observer -> Disposable in
            let request: R
            do {
                request = try createRequest(self.base)
                observer.on(.next(request))
                request.responseWith(completionHandler: { (response) in
                    if let error = response.error {
                        observer.onError(error)
                    } else {
                        observer.on(.completed)
                    }
                })

                if !self.base.startRequestsImmediately {
                    request.resume()
                }

                return Disposables.create {
                    request.cancel()
                }
            }
            catch let error {
                observer.on(.error(error))
                return Disposables.create()
            }
        }
    }


    public func request(_ method: Alamofire.HTTPMethod,
                        _ url: URLConvertible,
                        parameters: [String: Any]? = nil,
                        encoding: ParameterEncoding = URLEncoding.default,
                        headers: [String: String]? = nil
    )
        -> Observable<DataRequest>
    {
        return request { manager in
            return manager.request(url,
                                   method: method,
                                   parameters: parameters,
                                   encoding: encoding,
                                   headers: headers)
        }
    }


    public func request(urlRequest: URLRequestConvertible)
        -> Observable<DataRequest>
    {
        return request { manager in
            return manager.request(urlRequest)
        }
    }

    // MARK: data
    public func responseData(_ method: Alamofire.HTTPMethod,
                             _ url: URLConvertible,
                             parameters: [String: Any]? = nil,
                             encoding: ParameterEncoding = URLEncoding.default,
                             headers: [String: String]? = nil
    )
        -> Observable<(HTTPURLResponse, Data)>
    {
        return request(
                       method,
                       url,
                       parameters: parameters,
                       encoding: encoding,
                       headers: headers
        ).flatMap { $0.rx.responseData() }
    }

    public func data(_ method: Alamofire.HTTPMethod,
                     _ url: URLConvertible,
                     parameters: [String: Any]? = nil,
                     encoding: ParameterEncoding = URLEncoding.default,
                     headers: [String: String]? = nil
    )
        -> Observable<Data>
    {
        return request(
                       method,
                       url,
                       parameters: parameters,
                       encoding: encoding,
                       headers: headers
        ).flatMap { $0.rx.data() }
    }

    // MARK: string

    public func responseString(_ method: Alamofire.HTTPMethod,
                               _ url: URLConvertible,
                               parameters: [String: Any]? = nil,
                               encoding: ParameterEncoding = URLEncoding.default,
                               headers: [String: String]? = nil
    )
        -> Observable<(HTTPURLResponse, String)>
    {
        return request(
                       method,
                       url,
                       parameters: parameters,
                       encoding: encoding,
                       headers: headers
        ).flatMap { $0.rx.responseString() }
    }

    public func string(_ method: Alamofire.HTTPMethod,
                       _ url: URLConvertible,
                       parameters: [String: Any]? = nil,
                       encoding: ParameterEncoding = URLEncoding.default,
                       headers: [String: String]? = nil
    )
        -> Observable<String>
    {
        return request(
                       method,
                       url,
                       parameters: parameters,
                       encoding: encoding,
                       headers: headers
        )
            .flatMap { (request) -> Observable<String> in
                return request.rx.string()
        }
    }

    // MARK: JSON

    public func responseJSON(_ method: Alamofire.HTTPMethod,
                             _ url: URLConvertible,
                             parameters: [String: Any]? = nil,
                             encoding: ParameterEncoding = URLEncoding.default,
                             headers: [String: String]? = nil
    )
        -> Observable<(HTTPURLResponse, Any)>
    {
        return request(method,
                       url,
                       parameters: parameters,
                       encoding: encoding,
                       headers: headers
        ).flatMap { $0.rx.responseJSON() }
    }


    public func json(_ method: Alamofire.HTTPMethod,
                     _ url: URLConvertible,
                     parameters: [String: Any]? = nil,
                     encoding: ParameterEncoding = URLEncoding.default,
                     headers: [String: String]? = nil
    )
        -> Observable<Any>
    {
        return request(
                       method,
                       url,
                       parameters: parameters,
                       encoding: encoding,
                       headers: headers
        ).flatMap { $0.rx.json() }
    }

    // MARK: Upload
    public func upload(_ file: URL, urlRequest: URLRequestConvertible) -> Observable<UploadRequest> {

        return request { manager in
            return manager.upload(file, with: urlRequest)
        }
    }

    public func upload(_ data: Data, urlRequest: URLRequestConvertible) -> Observable<UploadRequest> {
        return request { manager in
            return manager.upload(data, with: urlRequest)
        }
    }


    public func upload(_ stream: InputStream,
                       urlRequest: URLRequestConvertible) -> Observable<UploadRequest> {
        return request { manager in
            return manager.upload(stream, with: urlRequest)
        }
    }

    // MARK: Download
    public func download(_ urlRequest: URLRequestConvertible,
                         to destination: @escaping DownloadRequest.DownloadFileDestination) -> Observable<DownloadRequest> {
        return request { manager in
            return manager.download(urlRequest, to: destination)
        }
    }


    public func download(resumeData: Data,
                         to destination: @escaping DownloadRequest.DownloadFileDestination) -> Observable<DownloadRequest> {
        return request { manager in
            return manager.download(resumingWith: resumeData, to: destination)
        }
    }
}

// MARK: Request - Common Response Handlers
extension Request: ReactiveCompatible {
}

extension Reactive where Base: DataRequest {

    // MARK: Defaults
    func validateSuccessfulResponse() -> DataRequest {
        return self.base.validate(statusCode: 200 ..< 300)
    }

    public func responseResult<T: DataResponseSerializerProtocol>(queue: DispatchQueue? = nil,
                                                                  responseSerializer: T)
        -> Observable<(HTTPURLResponse, T.SerializedObject)>
    {
        return Observable.create { observer in
            let dataRequest = self.base
                .response(queue: queue, responseSerializer: responseSerializer) { (packedResponse) -> Void in
                    switch packedResponse.result {
                    case .success(let result):
                        if let httpResponse = packedResponse.response {
                            observer.on(.next(httpResponse, result))
                        }
                            else {
                            observer.on(.error(RxAlamofireUnknownError))
                        }
                        observer.on(.completed)
                    case .failure(let error):
                        observer.on(.error(error as Error))
                    }
            }
            return Disposables.create {
                dataRequest.cancel()
            }
        }
    }

    public func result<T: DataResponseSerializerProtocol>(
                                                          queue: DispatchQueue? = nil,
                                                          responseSerializer: T)
        -> Observable<T.SerializedObject>
    {
        return Observable.create { observer in
            let dataRequest = self.validateSuccessfulResponse()
                .response(queue: queue, responseSerializer: responseSerializer) { (packedResponse) -> Void in
                    switch packedResponse.result {
                    case .success(let result):
                        if let _ = packedResponse.response {
                            observer.on(.next(result))
                        }
                            else {
                            observer.on(.error(RxAlamofireUnknownError))
                        }
                        observer.on(.completed)
                    case .failure(let error):
                        if packedResponse.response?.statusCode == 401 {
                            HyberLogger.info("UNAUTHORIZED. Incorrect: Token/session/phone")
                        }
                        observer.on(.error(error as Error))
                    }
            }
            return Disposables.create {
                dataRequest.cancel()
            }
        }
    }


    public func responseData() -> Observable<(HTTPURLResponse, Data)> {
        return responseResult(responseSerializer: DataRequest.dataResponseSerializer())
    }

    public func data() -> Observable<Data> {
        return result(responseSerializer: DataRequest.dataResponseSerializer())
    }


    public func responseString(encoding: String.Encoding? = nil) -> Observable<(HTTPURLResponse, String)> {
        return responseResult(responseSerializer: Base.stringResponseSerializer(encoding: encoding))
    }

    public func string(encoding: String.Encoding? = nil) -> Observable<String> {
        return result(responseSerializer: Base.stringResponseSerializer(encoding: encoding))
    }


    public func responseJSON(options: JSONSerialization.ReadingOptions = .allowFragments) -> Observable<(HTTPURLResponse, Any)> {
        return responseResult(responseSerializer: Base.jsonResponseSerializer(options: options))
    }

    public func json(options: JSONSerialization.ReadingOptions = .allowFragments) -> Observable<Any> {
        return result(responseSerializer: Base.jsonResponseSerializer(options: options))
    }


    public func responsePropertyList(options: PropertyListSerialization.ReadOptions = PropertyListSerialization.ReadOptions()) -> Observable<(HTTPURLResponse, Any)> {
        return responseResult(responseSerializer: Base.propertyListResponseSerializer(options: options))
    }

    public func propertyList(options: PropertyListSerialization.ReadOptions = PropertyListSerialization.ReadOptions()) -> Observable<Any> {
        return result(responseSerializer: Base.propertyListResponseSerializer(options: options))
    }

    // MARK: Request - Upload and download progress
    public func progress() -> Observable<RxProgress> {
        return Observable.create { observer in
            self.base.downloadProgress { progress in
                let rxProgress = RxProgress(bytesWritten: progress.completedUnitCount,
                                            totalBytes: progress.totalUnitCount)
                observer.onNext(rxProgress)
                if rxProgress.bytesWritten >= rxProgress.totalBytes {
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
        // warm up a bit :)
        .startWith(RxProgress(bytesWritten: 0, totalBytes: 0))
    }
}

extension Reactive where Base: DownloadRequest {
    public func progress() -> Observable<RxProgress> {
        return Observable.create { observer in
            self.base.downloadProgress { progress in
                let rxProgress = RxProgress(bytesWritten: progress.completedUnitCount,
                                            totalBytes: progress.totalUnitCount)
                observer.onNext(rxProgress)
                if rxProgress.bytesWritten >= rxProgress.totalBytes {
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
        // warm up a bit :)
        .startWith(RxProgress(bytesWritten: 0, totalBytes: 0))
    }
}

// MARK: RxProgress
public struct RxProgress {
    public let bytesWritten: Int64
    public let totalBytes: Int64

    public init(bytesWritten: Int64, totalBytes: Int64) {
        self.bytesWritten = bytesWritten
        self.totalBytes = totalBytes
    }
}

extension RxProgress {
    public var bytesRemaining: Int64 {
        return totalBytes - bytesWritten
    }

    public var completed: Float {
        if totalBytes > 0 {
            return Float(bytesWritten) / Float(totalBytes)
        }
            else {
            return 0
        }
    }
}

extension RxProgress: Equatable { }

public func == (lhs: RxProgress, rhs: RxProgress) -> Bool {
    return lhs.bytesWritten == rhs.bytesWritten &&
    lhs.totalBytes == rhs.totalBytes
}

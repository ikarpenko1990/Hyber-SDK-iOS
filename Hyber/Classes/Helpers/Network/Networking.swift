//
//  Networking.swift
//  Hyber-SDK-IOS
//
//  Created by Taras on 11/8/16.
//
//


import Alamofire
import CoreData
import Realm
import RealmSwift
import SwiftyJSON
import RxSwift


class Networking: NSObject {

    let disposeBag = DisposeBag()
    
    class func registerRequest(parameters: [String: Any]?, headers: [String: String]) -> Observable<Any> {
        return request(.post, kRegUrl, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .flatMap { response -> Observable<Any> in
                return response.validate(statusCode: 200..<300)
                    .validate(contentType: ["application/json", "text/json"])
                    .rx.json()
            }
            .map {
                json in
                let validJson = JSON(json)
                DataRealm.saveProfile(json: validJson)
                HyberLogger.info(validJson)
            return validJson
        }
    }

    class func updateDeviceRequest(parameters: [String: Any]?, headers: [String: String]) -> Observable<Any> {
        return request(.post, kUpdateUrl, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .flatMap { response -> Observable<Any> in
                return response.validate(statusCode: 200..<300)
                    .validate(contentType: ["application/json", "text/json"])
                    .rx.json()
        }
            .map { json in
                let data = json
                let validJson = JSON(data)
                DataRealm.updateDevice(json: validJson)
                HyberLogger.info(validJson)
                return validJson

        }
    }

    class func getMessagesRequest(parameters: [String: Any]?, headers: [String: String]) -> Observable<Any> {
        return request(.get, kGetMsgHistory, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.asyncInstance)
            .flatMap { response -> Observable<Any> in
                return response.validate(statusCode: 200..<300)
                    .validate(contentType: ["application/json", "text/json"])
                    .rx.json()
            }
            .map { json in
                let data = json
                let validJson = JSON(data)
                DataRealm.saveMessages(json: validJson)
                HyberLogger.debug(validJson)
                return validJson
        }
    }



    class func sentDeliveredStatus(parameters: [String: Any]? = nil, headers: [String: String]) -> Observable<Any> {

        return request(.post, kSendMsgDr, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .flatMap { response -> Observable<Any> in
                return response.validate(statusCode: 200..<500)
                    .rx.json()
        }

    }

    class func sentBiderectionalMessage(parameters: [String: Any]? = nil, headers: [String: String]) -> Observable<Any> {
        return request(.post, kSendMsgCallback, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .flatMap { response -> Observable<Any> in
                return response.validate(statusCode: 200..<500)
                    .rx.json()
        }
            .map { _ in
                HyberLogger.debug(HTTPURLResponse())
        }
    }


    //MARK: -New features
    class func deleteDevice(parameters: [String: Any]?, headers: [String: String]) -> Observable<Any> {
        return request(.post, kDeleteDevice, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .flatMap { response -> Observable<Any> in
                return response.validate(statusCode: 200..<300)
                    .validate(contentType: ["application/json", "text/json"])
                    .rx.json()
        }
            .map { json in
                let data = json
                let validJson = JSON(data)
                let error = validJson["error"]
                if error != nil {
                    DataRealm.responseError(error: error)
                }
                HyberLogger.info(validJson)
                return validJson
        }
    }


    class func getDeviceInfoRequest(parameters: [String: Any]?, headers: [String: String]) -> Observable<Any> {
        return request(.get, kGetDeviceInfo, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .flatMap { response -> Observable<Any> in
                return response.validate(statusCode: 200..<500)
                    .validate(contentType: ["application/json", "text/json", "text/plain"])
                    .rx.json()
            }
            .map { json in
                let data = json
                let validJson = JSON(data)
                DataRealm.saveDeiveList(json:validJson)
            HyberLogger.debug(validJson)
            return validJson
        }
    }
    
    //MARK: - Method with Handler
    class func getMessagesArea(parameters: [String: Any]?, headers: [String: String], completionHandler: @escaping (AnyObject?, Error?) -> ()) {
        Alamofire.request(kGetMsgHistory, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers) .responseJSON { response in
            switch response.result {
            case .success(let value):
                completionHandler(value as AnyObject?, nil)
            case .failure(let error):
                completionHandler(nil, error)
                HyberLogger.error(error)
            }
        }
    }
    
    class func getDeviceArea(parameters: [String: Any]?, headers: [String: String], completionHandler: @escaping (AnyObject?, Error?) -> ()) {
        Alamofire.request(kGetDeviceInfo, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers) .responseJSON { response in
            switch response.result {
            case .success(let value):
                completionHandler(value as AnyObject?, nil)
            case .failure(let error):
                completionHandler(nil, error)
                HyberLogger.error(error)
            }
        }
    }


}

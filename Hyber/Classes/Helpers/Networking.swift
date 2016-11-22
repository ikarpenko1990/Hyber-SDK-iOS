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
import ObjectMapper
import AlamofireObjectMapper
import RxSwift


class Networking: NSObject{
    
    let disposeBag = DisposeBag()

    class  func registerRequest(parameters: [String: Any]?, headers: [String:String] ) -> Observable<Any> {
        return request(.post, kRegUrl , parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .flatMap {response ->Observable<Any> in
                return response.validate(statusCode: 200..<300)
                    .validate(contentType: ["application/json","text/json"])
                    .rx.json()
            }
            .map{
                json in
                let validJson = JSON(json)
                let session = validJson["session"]
                let error = validJson["error"]
                if error != nil{
                    responseError(error: error)
                }
                let user = User()
                user.mId = validJson["userPhone"].string
                user.isActive = true
                let newSession = Session()
                newSession.mExpirationDate = session["expirationDate"].string
                newSession.mToken = session["authToken"].string
                newSession.mRefreshToken = session["refreshToken"].string
                newSession.mUser = user
                
                let realm = try Realm()
                try realm.write {
                    realm.add(newSession, update:true)
                    realm.add(user, update:true)
                    HyberLogger.info("Data Saved")
                }
                HyberLogger.info(validJson)
            return validJson
            }
        }
    
    class func updateDeviceRequest(parameters: [String: Any]?, headers: [String:String] )  -> Observable<Any> {
        return request(.post, kUpdateUrl , parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .flatMap {response ->Observable<Any> in
                return response.validate(statusCode: 200..<300)
                    .validate(contentType: ["application/json","text/json"])
                    .rx.json()
            }
            .map { json in
                let data = json
                let validJson = JSON(data)
                let error = validJson["error"]
                if error != nil{
                    responseError(error: error)
                }
            
            return validJson
                
        }        
    }
    
    
    
    class func refreshAuthTokenRequest(parameters: [String: Any]?, headers: [String:String] )  -> Observable<Any> {
        return request(.post, kRefreshToken , parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
            .flatMap {response ->Observable<Any> in
                return response.validate(statusCode: 200..<300)
                    .validate(contentType: ["application/json","text/json"])
                    .rx.json()
            }
            .map {json in
                let data = json
                let validJson = JSON(data)
                let session = validJson["session"]
                let error = validJson["error"]
                if error != nil{
                    responseError(error: error)
                } else {
                    let newSession = Session()
                    newSession.mExpirationDate = session["expirationDate"].string
                    newSession.mToken = session["authToken"].string
                    newSession.mRefreshToken = session["refreshToken"].string
                    
                    let realm = try Realm()
                    try realm.write {
                        realm.add(newSession, update:true)
                        HyberLogger.info("Data Saved")
                    }

                }
                return validJson
        }
    }
 
    
    class func getMessagesRequest(parameters: [String: Any]?, headers: [String:String] )  -> Observable<Any> {
        return request(.post, kGetMsgHistory , parameters: parameters, encoding: JSONEncoding.default, headers: headers)
          .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.asyncInstance)
            .flatMap {response ->Observable<Any> in
                return response.validate(statusCode: 200..<300)
                    .validate(contentType: ["application/json","text/json"])
                    .rx.json()
            }
            .map {json in
                let data = json
                let validJson = JSON(data)
                let message = validJson["messages"].arrayObject
                let error = validJson["error"]
                    if error != nil{
                        responseError(error: error)
                }
                let realm = try! Realm()
                let messages = List<Message>()
                
                if let jsonArray =  message as? [[String:Any]] {
                    for  messagesArray in jsonArray {
                        
                        let newMessages = Message()
                        
                        newMessages.messageId = messagesArray["messageId"] as? String
                        newMessages.mTitle = messagesArray["from"] as? String
                        newMessages.mPartner = messagesArray["partner"] as? String
                        newMessages.mBody = messagesArray["text"] as? String
                        newMessages.mDate = ((messagesArray["drTime"] as? Double)! * 0.001) //need fix type
                            if messagesArray["drTime"] != nil {
                                newMessages.isReported = true
                            }
                       
                            if let optionsArray = messagesArray["options"] as? [String:Any] {
                                newMessages.mImageUrl = optionsArray["img"] as? String
                                newMessages.mButtonUrl = optionsArray["action"] as? String
                                newMessages.mButtonText = optionsArray["caption"] as? String
                            }
                        
                        messages.append(newMessages)
                            try! realm.write {
                                realm.add(newMessages, update: true)
                            }
                       
                      }
                }
                print(validJson)
            return validJson
        }
    }
    

    
    class func sentDeliveredStatus(parameters: [String: Any]? = nil, headers: [String:String] )  -> Observable<Any> {
        
        return request(.post, kSendMsgDr , parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .flatMap {response ->Observable<Any> in
                return response.validate(statusCode: 200..<300)
                    .validate(contentType: ["application/json","text/json"])
                    .rx.json()
                 print("Sented delivery rate")
            }
       
        }
   
    class func sentBiderectionalMessage(parameters: [String: Any]? = nil, headers: [String:String] )  -> Observable<Any> {
        return request(.post, kSendMsgCallback , parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .flatMap {response ->Observable<Any> in
                return response.validate(statusCode: 200..<300)
                    .validate(contentType: ["application/json","text/json"])
                    .rx.json()
        }
            .map{_ in 
                HyberLogger.debug(HTTPURLResponse())
            }
    }
    
    class func responseError(error: JSON) {
            if error["code"] == 2133{
                Hyber.refreshAuthToken()
                HyberLogger.debug("Trying refresh token")
            } else {
                HyberLogger.error(error)
            }
    
    }
    
    class func deleteDevice(parameters: [String: Any]?, headers: [String:String] )  -> Observable<Any> {
        return request(.post, kUpdateUrl , parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .flatMap {response ->Observable<Any> in
                return response.validate(statusCode: 200..<300)
                    .validate(contentType: ["application/json","text/json"])
                    .rx.json()
            }
            .map {json in
                let data = json
                let validJson = JSON(data)
                let error = validJson["error"]
                if error != nil{
                    responseError(error: error)
                }
                return validJson
        }
    }
    
    
    class func getDeviceInfoRequest(parameters: [String: Any]?, headers: [String:String] )  -> Observable<Any> {
        return request(.get, kUpdateUrl , parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .flatMap {response ->Observable<Any> in
                return response.validate(statusCode: 200..<500)
                    .validate(contentType: ["application/json","text/json","text/plain"])
                    .rx.json()
            }
            .map {json in
                let data = json
                let validJson = JSON(data)
                let error = validJson["error"]
                if error != nil{
                    responseError(error: error)
                }
                
                return validJson
        }
    }
    
}

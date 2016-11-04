//
//  HyberRealmData.swift
//  Pods
//
//  Created by Taras on 10/25/16.
//
//

import UIKit
import RealmSwift
import SwiftyJSON

/*Initialize realm */
public extension Hyber{
    
  public  static let urealm : Realm = {
//    var config = Realm.Configuration()
//    let path = Bundle.main.url(forResource: "Hyber", withExtension: "realm")  
//    config.fileURL = path
//    
//    Realm.Configuration.defaultConfiguration = config
//    
//    HyberLogger.debug(Realm.Configuration.defaultConfiguration.fileURL!)
        return try! Realm()
    }()
    
    public func addUser(jsonArray: [String:AnyObject]) {
        do {
            try Hyber.urealm.write {
                
                let newUser = User()
                
                Hyber.urealm.add(newUser, update: true)
            }
            
        } catch {
            HyberLogger.info("registration failed: \(error), please insert correct data")
        }
    }
    
    
    
    public func fetchMessages (messageArray: [String: AnyObject]) {
        
        do {
            try Hyber.urealm.write {
                
                let newMessage = Message()
                
                Hyber.urealm.add(newMessage, update: false)
                
            }
            
        } catch {
            HyberLogger.info("Message fetching error: \(error)")
        }
        
    }
    
    public func refreshSerrion(sessionArray:[String:AnyObject]) {
        do {
            try Hyber.urealm.write {
                
                let newSession = Session()
                
                Hyber.urealm.add(newSession, update: false)
                
            }
            
        } catch {
            HyberLogger.info("Refresh tocken failed: \(error)")
        }
    }
    
    //reading methods
    public func readMessages() {
        let  Messages = Hyber.urealm.objects(Message)
        HyberLogger.debug("Message list: " , Messages)
        
    }
    
    public func getUser() {
        let  Users = Hyber.urealm.objects(User)
        HyberLogger.debug("Users: ",Users)
        
    }
    public func getToken() {
        let userToken  = Hyber.urealm.objects(Session)
        HyberLogger.info("Token: ", userToken)
    }
    
   
}

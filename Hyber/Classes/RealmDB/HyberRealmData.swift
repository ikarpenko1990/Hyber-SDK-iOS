//
//  HyberRealmData.swift
//  Pods
//
//  Created by Taras on 10/25/16.
//
//

import UIKit
import RealmSwift
import Realm

/*Initialize realm */

public class HyberRealmData: RLMObject {
    
 
    
    let uiRealm = try! Realm()
    
    var storedData : Results<User>!
    
    public func readData(){
        
        storedData = uiRealm.objects(User.self)
        print("Stored data: \(storedData)")
    }

    
    func bundleURL(_ name: String) -> URL? {
        return Bundle.main.url(forResource: name, withExtension: "realm")
    }
    
    public func saveData(){
            let newStoredData = User()
            try! uiRealm.write{
                
                uiRealm.add(newStoredData)
           
            }
        
        print("Saved data: \(newStoredData)")
        }
        
    
    }



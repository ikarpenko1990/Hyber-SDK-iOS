//
//  ViewController.swift
//  Hyber
//
//  Created by 4taras4 on 10/20/2016.
//  Copyright (c) 2016 4taras4. All rights reserved.
//

import UIKit
import Hyber
import UserNotifications
import Firebase

class ViewController: UIViewController {
    @IBAction func registerBtn(_ sender: AnyObject) {
        HyberFirebaseMessagingDelegate.sharedInstance.registerForRemoteNotification()
       // Hyber.registration(phoneId: "380937431520", hyberToken: "testtocken")
       // Hyber.testDeliveredData()
        HyberFirebaseMessagingDelegate.sharedInstance.configureFirebaseMessaging()
        
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
   
    
}

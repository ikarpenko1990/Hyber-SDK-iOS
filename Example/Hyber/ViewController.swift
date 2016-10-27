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

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    @IBAction func registerBtn(_ sender: AnyObject) {
        registerForRemoteNotification()
        Hyber.registration(phoneId: "380937431520", hyberToken: "testtocken")
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
            
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    
}

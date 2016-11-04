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
        Hyber.registration(phoneId: "380937431520", hyberToken: "b5a5b6f4-5af7-11e6-8b77-86f30ca893d3")
//        Hyber.testDeliveredData()
        }
    
    @IBAction func deviceInfoAction(_ sender: Any) {
    
        Hyber.updateDevice(fcmToken:"fkrNxuho7a8:APA91bFcE2Qe73jVuLOILTLq0Lfc76z_Z9f5PX_BVjHFATa2R07ZTd4OR5l75lY3j6jnGD0WD2wnixieSv2hX5Pp9Tzs6LOcir5mlAxwURU-n5fBbiGaxs_E-s1V3KJAnKHZSmCsMPAg")
        
    }
    
    @IBAction func deleteDeviceAction(_ sender: Any) {
        Hyber.deleteDevice(deviceId: "27")
    }
    
    @IBAction func getMessageAction(_ sender: Any) {
        Hyber.getMessageList()
        print("button pressed")
    }
    @IBAction func refreshToken(_ sender: Any) {
        Hyber.refreshAuthToken()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        let specimens = try! Realm().objects(Messages.self)
//        print(specimens)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
   
    
}

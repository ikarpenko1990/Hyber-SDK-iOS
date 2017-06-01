//
//  SettingsViewController.swift
//  Hyber
//
//  Created by Taras Markevych on 5/25/17.
//  Copyright © 2017 Incuube. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    let def = UserDefaults.standard
    var newKey = ""
    @IBAction func saveAction(_ sender: Any) {
        newKey = apiKeyTextField.text!
        def.set(newKey, forKey: "clientApiKey")
        def.synchronize()
        self.showAllertMessage(title: "Attention", message: "Application will relaunch, for reset settings" )
    }
    
    @IBOutlet var bundleLabel: UIView!
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func resetAction(_ sender: Any) {
        def.removeObject(forKey: "clientApiKey")
        newKey = "b5a5b6f4-5af7-11e6-8b77-86f30ca893d3"
        apiKeyTextField.text! = newKey
        def.set(newKey, forKey: "clientApiKey")
        def.synchronize()
    }
    
    @IBOutlet weak var apiKeyTextField: UITextField!
    @IBOutlet weak var fcmTokenLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            self.apiKeyTextField.text = gedApiKeyTest()
            if let defauls = self.def.object(forKey: "fcmToken") {
                 self.fcmTokenLabel.text = defauls as? String
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

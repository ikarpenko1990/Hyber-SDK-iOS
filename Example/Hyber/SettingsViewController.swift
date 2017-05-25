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
        def.set(newKey, forKey: "apikey")
        def.synchronize()
        self.dismiss(animated: true)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func resetAction(_ sender: Any) {
        def.removeObject(forKey: "apikey")
        def.synchronize()
        self.viewDidLoad()
    }
    
    @IBOutlet weak var apiKeyTextField: UITextField!
    @IBOutlet weak var fcmTokenLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            self.apiKeyTextField.text = gedApiKeyProd()
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

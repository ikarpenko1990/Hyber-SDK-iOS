//
//  SettingsViewController.swift
//  Hyber
//
//  Created by Taras Markevych on 5/25/17.
//  Copyright © 2017 Incuube. All rights reserved.
//
import Hyber
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
    
    @IBOutlet weak var bundleIdlabel: UILabel!
    @IBOutlet weak var currentServerLabel: UILabel!
    @IBOutlet weak var apiKeyTextField: UITextField!
    @IBOutlet weak var fcmTokenLabel: UILabel!
    @IBOutlet weak var changeServer: UIButton!
    @IBAction func changeServerAction(_ sender: Any) {
        self.getActionView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            self.apiKeyTextField.text = gedApiKeyTest()
            self.currentServerLabel.text = "Current server \(Hyber.currentLink.current)"
            self.bundleIdlabel.text = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String
            if let defauls = self.def.object(forKey: "fcmToken") {
                 self.fcmTokenLabel.text = defauls as? String
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getActionView()  {
        let optionMenu = UIAlertController(title: "Current server", message:  Hyber.currentLink.current , preferredStyle: .actionSheet)
        let test28 = UIAlertAction(title: "Server 28", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            _ = Hyber.currentLink.mainUrl(url:"http://10.0.4.28/")
            self.currentServerLabel.text = "Current server \(Hyber.currentLink.current)"

            
        })
        let test29 = UIAlertAction(title: "Server 29", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            _ =  Hyber.currentLink.mainUrl(url:"http://10.0.4.29/")
            self.currentServerLabel.text = "Current server \(Hyber.currentLink.current)"

        })
        let test30 = UIAlertAction(title: "Server 30", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            _ =  Hyber.currentLink.mainUrl(url:"http://10.0.4.30/")
            self.currentServerLabel.text = "Current server \(Hyber.currentLink.current)"

        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(test28)
        optionMenu.addAction(test29)
        optionMenu.addAction(test30)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }

}


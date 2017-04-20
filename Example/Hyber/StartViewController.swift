//
//  StartViewController.swift
//  Hyber
//
//  Created by Taras on 11/22/16.
//  Copyright © 2016 Incuube. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    let defaults = UserDefaults.standard

    @IBAction func validateLogin(sender: UIButton) {
            self.performSegue(withIdentifier: "firstSegue", sender:sender)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear( true)
        firstScreen()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstScreen()
    }
   
    func firstScreen() {
        if defaults.string(forKey: "startScreen") == "1" {
            self.performSegue(withIdentifier: "firstSegue", sender: self)
            } else {
                if let vc3 = self.storyboard?.instantiateViewController(withIdentifier: "login") as? ViewController {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController!.present(vc3, animated: true, completion: nil)
            }
        }
    }

}

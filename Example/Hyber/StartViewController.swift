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
        // validate login
    
            self.performSegue(withIdentifier: "firstSegue", sender:sender)
     
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear( true)
        firstScreen()

    }
    override func viewDidLoad() {
        super.viewDidLoad()
       self.performSegue(withIdentifier: "firstSegue", sender: self)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

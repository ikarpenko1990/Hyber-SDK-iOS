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

class ViewController: UIViewController  {
    let defaults = UserDefaults.standard
    @IBOutlet weak var registrationBtn: UIButton!
    @IBAction func registetrationAction(_ sender: UIButton) {
        
    Hyber.registration(phoneId: numberTextFiled.text!, completionHandler: { (success) -> Void in
            if success {
                self.defaults.set("1", forKey: "startScreen")
                self.defaults.synchronize()
                self.dismiss(animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Alert", message: "Please input correct phone number", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
        
    }
    
    @IBOutlet weak var numberTextFiled: UITextField!
    
    @IBAction func tabGestureAction(_ sender: Any) {
        numberTextFiled.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDesign()
        setUpBackground()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
            view.addGestureRecognizer(tap)
    }
       
    func buttonDesign() {
        registrationBtn.layer.cornerRadius = 20
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func setUpBackground() {
        let gradient: CAGradientLayer = CAGradientLayer()
            gradient.colors = [UIColor.init(red: 87, green: 115, blue: 249).cgColor,
                           UIColor.init(red: 191, green: 82, blue: 251).cgColor]
            gradient.locations = [0.0 , 1.0]
            gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
            gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    override func resignFirstResponder() -> Bool {
        numberTextFiled.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
}



extension ViewController: UITextFieldDelegate {
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
   internal func textField(_ shouldChangeCharactersIntextField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let numberOnly = NSCharacterSet.init(charactersIn: "0123456789")
        let stringFromTextField = NSCharacterSet.init(charactersIn: string)
        let strValid = numberOnly.isSuperset(of: stringFromTextField as CharacterSet)
        
        return strValid
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }

}

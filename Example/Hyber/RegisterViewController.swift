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
import CountryPicker
import libPhoneNumber_iOS

class ViewController: UIViewController, CountryPickerDelegate  {

    var phoneCodeLoad: String?
    let notificationIdentifier: String = "GetNewsetting"

    let defaults = UserDefaults.standard
//MARK: - Outlets
    @IBOutlet weak var countryCodeBtn: UIButton!
    
    @IBAction func codePickerAction(_ sender: Any) {
        if countryPhoneCodePicker.isHidden == true {
            countryPhoneCodePicker.isHidden = false
            view.endEditing(true)
        } else {
            countryPhoneCodePicker.isHidden = true
        }
    }
  
    @IBOutlet weak var numberTextFiled: UITextField!
    @IBAction func settingAction(_ sender: Any) {
        let settingViewController = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        self.present(settingViewController, animated: true)
    }
    
    @IBOutlet weak var registrationBtn: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    @IBAction func registetrationAction(_ sender: UIButton) {
        var phoneNumber = phoneCodeLoad! + numberTextFiled.text!
        phoneNumber.remove(at: phoneNumber.startIndex)
        print(phoneNumber)
        
        Hyber.registration(phoneId: phoneNumber, password:phoneNumber, completionHandler: { (success) -> Void in
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
    
    @IBOutlet weak var countryPhoneCodePicker: CountryPicker!
    
    @IBAction func tabGestureAction(_ sender: Any) {
        numberTextFiled.resignFirstResponder()
        countryPhoneCodePicker.isHidden = true
    }
//MARK: - Controller functions
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        countryPhoneCodePicker.isHidden = true
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDesign()
        setUpBackground()
        //Gestures
        self.defaults.set("2", forKey: "startScreen")
        self.defaults.synchronize()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        //Country codes
        let locale = Locale.current
        let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String?
        let phoneNumberUtil = NBPhoneNumberUtil.sharedInstance()
        phoneCodeLoad = "+\(phoneNumberUtil!.getCountryCode(forRegion: code)!)" as String?
        countryCodeBtn.setTitle(phoneCodeLoad, for: .normal)
        countryPhoneCodePicker.countryPickerDelegate = self
        countryPhoneCodePicker.setCountry(code!)
    }
    
    // MARK: - CountryPhoneCodePicker Delegate
    
    public func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        DispatchQueue.main.async {
            self.countryCodeBtn.setTitle(phoneCode, for:.normal)
        }
    }

    func buttonDesign() {
        registrationBtn.layer.cornerRadius = 20
        settingButton.layer.cornerRadius = 5
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
        countryPhoneCodePicker.isHidden = true
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
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil    
    }
    
    func checkEnglishPhoneNumberFormat(string: String?, str: String?) -> Bool{
        
        if string == ""{ //BackSpace
            
            return true
            
        }else if str!.characters.count < 3{
            
            if str!.characters.count == 1{
                
                numberTextFiled.text = "("
            }
            
        }else if str!.characters.count == 5{
            
            numberTextFiled.text = numberTextFiled.text! + ") "
            
        }else if str!.characters.count == 10{
            
            numberTextFiled.text = numberTextFiled.text! + "-"
            
        }else if str!.characters.count > 14{
            
            return false
        }
        
        return true
    }
}

extension UIViewController {
    
    /// UIAlertView
    ///
    /// - Parameters:
    ///   - title: String of title
    ///   - message: message
    public func showAllertMessage(title:String,  message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in
        exit(0)}
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
}

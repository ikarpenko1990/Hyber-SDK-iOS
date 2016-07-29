//
//  ViewController.swift
//  HyberDemo
//
//  Created by Vitalii Budnik on 7/20/16.
//  Copyright © 2016 Global Message Services. All rights reserved.
//

import UIKit
import Hyber
import Firebase

class ViewController: UIViewController {
	
	@IBOutlet weak var phoneNumberTextField: UITextField!
	@IBOutlet weak var firebaseMessagingTokenTextField: UITextField!
	@IBOutlet weak var hyberTokenTextField: UITextField!
	@IBOutlet weak var apnsDeviceTokenTextField: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		refreshData()
		
		NSNotificationCenter.defaultCenter()
			.addObserver(self,
			             selector: #selector(onFirebaseMessagingTokenRefresh(_:)),
			             name: kFIRInstanceIDTokenRefreshNotification,
			             object: .None)
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// ~1.5-2.0 seconds needed to recieve deviceToken, after application.registerForRemoteNotifications() call
		let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 1.5))
		dispatch_after(delay, dispatch_get_main_queue()) { [weak self] in
			self?.refreshData()
		}
		
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func onFirebaseMessagingTokenRefresh(notification: NSNotification?) {
		
		let firebaseMessagingToken = FIRInstanceID.instanceID().token()
		
		firebaseMessagingTokenTextField.text = firebaseMessagingToken
		
	}
	
	func registerUserNotificationSettings() {
		let notificationSettings = UIUserNotificationSettings(
			forTypes: [.Alert, .Sound, .Badge],
			categories: .None)
		
		UIApplication.sharedApplication()
			.registerUserNotificationSettings(notificationSettings)
		
	}
	
	@IBAction func registerForNotificationsPressed(sender: UIButton) {
		registerUserNotificationSettings()
	}
	
	@IBAction func addSubscriberPressed(sender: UIButton) {
		
		guard let phoneNumber = UInt64(phoneNumberTextField.text ?? "0") else {
			print("ERROR: Wrong phone number")
			return
		}
		
		Hyber.addSubscriber(phoneNumber, email: .None) { [weak self] hyberResult in
			
			guard let hyberToken = hyberResult.value else {
				print("ERROR: hyberResult - \(hyberResult.error)")
				return
			}
			
			print("hyberToken = \(hyberToken)")
			
			self?.refreshData()
			
		}
		
	}
	
	@IBAction func refreshPressed(sender: UIButton) {
		refreshData()
	}
	
	internal func refreshData() {
		firebaseMessagingTokenTextField.text = HyberFirebaseMessagingDelegate.sharedInstance.firebaseMessagingToken ?? Hyber.firebaseMessagingToken
		hyberTokenTextField.text = Hyber.hyberDeviceId > 0 ? "\(Hyber.hyberDeviceId)" : .None
		apnsDeviceTokenTextField.text = Hyber.apnsToken
		
		if phoneNumberTextField.text?.isEmpty ?? true,
			let phoneNumber = Hyber.registeredUserPhone where phoneNumber > 0 {
			phoneNumberTextField.text = "\(phoneNumber)"
		}
		
	}
	
	@IBAction func recognizedTapGetsure(sender: UITapGestureRecognizer) {
		resignFirstResponder()
	}
	
	override func resignFirstResponder() -> Bool {
		phoneNumberTextField.resignFirstResponder()
		firebaseMessagingTokenTextField.resignFirstResponder()
		hyberTokenTextField.resignFirstResponder()
		apnsDeviceTokenTextField.resignFirstResponder()

		return super.resignFirstResponder()
	}
	
	
	@IBAction func hyberSignOutPressed(sender: UIButton) {
		
		Hyber.signOut()
		
		refreshData()
		
	}
	
	@IBAction func hyberVerifyButtonPressed(sender: UIButton) {
		
		if Hyber.verify() {
			print("Ok")
		} else {
			print("Something went wrong")
		}
		
	}
}

extension ViewController: UITextFieldDelegate {
	
	internal func textFieldShouldReturn(textField: UITextField) -> Bool {
		resignFirstResponder()
		return true
	}
	
}

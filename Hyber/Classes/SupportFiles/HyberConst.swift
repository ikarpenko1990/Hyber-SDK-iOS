//
//  HyberConst.swift
//  Pods
//
//  Created by Taras on 10/21/16.
//
//

import CoreData

//Device Info
let kOSType = "ios"
let kOSVersion = UIDevice.current.systemVersion
let kDeviceType = "\(UIDevice.current.modelType)"
let kDeviceName = "\(UIDevice.current.modelName)"
let kBundleID = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String

let kHyberClientAPIKey = UserDefaults.standard.string(forKey:"clientApiKey")
let kFCM = UserDefaults.standard.string(forKey: "fcmToken")

let kRegUrl = "https://mobile.hyber.im/v1/device/registration"
let kUpdateUrl = "https://mobile.hyber.im/v1/device/update"
let kSendMsgDr = "https://push-dr.hyber.im/v1/message/dr"
let kGetMsgHistory = "https://mobile.hyber.im/v1/message/history"
let kSendMsgCallback = "https://push-callback.hyber.im/v1/message/callback"

//** Features relise **//
let kDeleteDevice = "https://mobile.hyber.im/v1/device/revoke"
let kGetDeviceInfo = "https://mobile.hyber.im/v1/device/all"



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

let kRegUrl = "http://46.101.192.217/mobile/api/v1/device/registration"
let kUpdateUrl = "http://46.101.192.217/mobile/api/v1/device/update"
let kSendMsgDr = "http://46.101.192.217/mobile/api/v1/message/dr"
let kGetMsgHistory = "http://46.101.192.217/mobile/api/v1/message/history"
let kSendMsgCallback = "http://46.101.192.217/mobile/api/v1/message/callback"

//** Features relise **//
let kDeleteDevice = "http://46.101.192.217/mobile/api/v1/device/revoke"
let kGetDeviceInfo = "http://46.101.192.217/mobile/api/v1/device/all"

//46.101.192.217
//185.46.89.20

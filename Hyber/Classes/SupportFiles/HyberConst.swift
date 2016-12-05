//
//  HyberConst.swift
//  Pods
//
//  Created by Taras on 10/21/16.
//
//

import CoreData

//Device Info
let kOSType = "iPhone OS"
let kOSVersion = UIDevice.current.systemVersion
let kDeviceType = "\(UIDevice.current.modelType)"
let kDeviceName = "\(UIDevice.current.modelName)"
let kUUID = UIDevice.current.identifierForVendor!.uuidString
let kBundleID = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String

let kHyberClientAPIKey = UserDefaults.standard.string(forKey:"clientApiKey")
let kFCM = UserDefaults.standard.string(forKey: "fcmToken")

let kRegUrl = "https://mobile.hyber.im/register/device"
let kUpdateUrl = "https://mobile.hyber.im/update/device"
let kRefreshToken =  "https://mobile.hyber.im/refreshtoken/device"
let kSendMsgDr = "https://push-dr.hyber.im"
let kGetMsgHistory = "https://mobile.hyber.im/messages/history"
let kSendMsgCallback = "https://push-callback.hyber.im"

//** Features relise **//
let kDeleteDevice = "/mobile-abonents/api/v1/device/delete"
let kDR = "https://push-dr.hyber.im"
let kGetDeviceInfo = "/mobile-abonents/api/v1/device/me"


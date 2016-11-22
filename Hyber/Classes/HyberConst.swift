//
//  HyberConst.swift
//  Pods
//
//  Created by Taras on 10/21/16.
//
//

import CoreData

let baseUrlDev = "http://185.46.89.20"
let baseUrlTest = "http://46.101.192.217"
let baseURL = "production"

//API
let kHyberClientAPIKey = UserDefaults.standard.string(forKey:"clientApiKey")
let kFCM = UserDefaults.standard.string(forKey: "fcmToken")
let kRegUrl = baseUrlTest + "/mobile-abonents/register/device"
let kUpdateUrl = baseUrlTest + "/mobile-abonents/update/device"
let kRefreshToken = baseUrlTest + "/mobile-abonents/refreshtoken/device"
let kSendMsgDr = "http://46.101.192.217/push-dr-receiver/sdk_api/dr"
let kGetMsgHistory = baseUrlTest + "/mobile-abonents/messages/history"
let kSendMsgCallback = baseUrlTest + "/push-callback-receiver/api/callback"

//** Features relise **//
let kDeleteDevice = baseUrlTest + "/mobile-abonents/api/v1/device/delete"
let kDR = baseUrlTest + "/push-dr-receiver/sdk_api/dr"
let kGetDeviceInfo = baseUrlTest + "/mobile-abonents/api/v1/device/me"

//Device Info
let kOSType = "iPhone OS"
let kOSVersion = UIDevice.current.systemVersion
let kDeviceType = "\(UIDevice.current.modelType)"
let kDeviceName = UIDevice.current.modelName
let kUUID = UIDevice.current.identifierForVendor!.uuidString
let kBundleID = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String


//
//  HyberConst.swift
//  Pods
//
//  Created by Taras on 10/21/16.
//
//

import CoreData

let baseUrlDev = "http://185.46.89.20"
let baseUrlTest = "46 server"
let baseURL = "production"

//API
let kHyberClientAPIKey = UserDefaults.standard.string(forKey:"clientApiKey")
let kFCM = UserDefaults.standard.string(forKey: "fcmToken")
let kRegUrl = baseUrlDev + "/mobile-abonents/register/device"
let kUpdateUrl = baseUrlDev + "/mobile-abonents/update/device"
let kRefreshToken = baseUrlDev + "/mobile-abonents/refreshtoken/device"
let kSendMsgDr = "http://185.46.89.20/push-dr-receiver/sdk_api/dr"
let kGetMsgHistory = baseUrlDev + "/mobile-abonents/messages/history"
let kSendMsgCallback = "http://185.46.89.20/push-callback-receiver/api/callback"

//** Features relise **//
let kDeleteDevice = baseUrlDev + "/mobile-abonents/api/v1/device/delete"
let kDR = baseUrlDev + "/push-dr-receiver/sdk_api/dr"
let kGetDeviceInfo = baseUrlDev + "/mobile-abonents/api/v1/device/me"

//Device Info
let kOSType = "iPhone OS"
let kOSVersion = UIDevice.current.systemVersion
let kDeviceType = "\(UIDevice.current.modelType)"
let kDeviceName = UIDevice.current.modelName
let kUUID = UIDevice.current.identifierForVendor!.uuidString
let kBundleID = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String


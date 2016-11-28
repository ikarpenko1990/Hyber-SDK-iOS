//
//  HyberConst.swift
//  Pods
//
//  Created by Taras on 10/21/16.
//
//

import CoreData

let baseUrlDev = "http://185.46.89.20/"
let baseUrlTest = "http://46.101.192.217/"
let baseURL = "production"



let kHyberClientAPIKey = UserDefaults.standard.string(forKey:"clientApiKey")
let kFCM = UserDefaults.standard.string(forKey: "fcmToken")

//Release
let kRegUrl = "https://mobile.hyber.im/register/device"
let kUpdateUrl = "https://mobile.hyber.im/update/device"
let kRefreshToken =  "https://mobile.hyber.im/refreshtoken/device"
let kSendMsgDr = "https://push-dr.hyber.im"
let kGetMsgHistory = "https://mobile.hyber.im/messages/history"
let kSendMsgCallback = "https://push-callback.hyber.im"

//** Features relise **//
let kDeleteDevice = baseUrlDev + "/mobile-abonents/api/v1/device/delete"
let kDR = "https://push-dr.hyber.im"
let kGetDeviceInfo = baseUrlDev + "/mobile-abonents/api/v1/device/me"

////API Test 185
//let kRegUrl = baseUrlDev + "mobile-abonents/register/device"
//let kUpdateUrl = baseUrlDev + "mobile-abonents/update/device"
//let kRefreshToken =  baseUrlDev + "mobile-abonents/refreshtoken/device"
//let kSendMsgDr = "http://185.46.89.20/push-dr-receiver/sdk_api/dr"
//let kGetMsgHistory =  baseUrlDev + "mobile-abonents/messages/history"
//let kSendMsgCallback =  baseUrlDev + "push-callback-receiver/api/callback"
//
////** Features relise **//
//let kDeleteDevice = baseUrlDev + "/mobile-abonents/api/v1/device/delete"
//let kDR = "https://push-dr.hyber.im"
//let kGetDeviceInfo = baseUrlDev + "/mobile-abonents/api/v1/device/me"

//////API Test 46
//let kRegUrl = baseUrlTest + "mobile-abonents/register/device"
//let kUpdateUrl = baseUrlTest + "mobile-abonents/update/device"
//let kRefreshToken =  baseUrlTest + "mobile-abonents/refreshtoken/device"
//let kSendMsgDr = "http://46.101.192.217/push-dr-receiver/sdk_api/dr"
//let kGetMsgHistory =  baseUrlTest + "mobile-abonents/messages/history"
//let kSendMsgCallback =  baseUrlTest + "push-callback-receiver/api/callback"
//
////** Features relise **//
//let kDeleteDevice = baseUrlDev + "/mobile-abonents/api/v1/device/delete"
//let kDR = "http://46.101.192.217/push-dr-receiver/sdk_api/dr"
//let kGetDeviceInfo = baseUrlDev + "/mobile-abonents/api/v1/device/me"

//Device Info
let kOSType = "iPhone OS"
let kOSVersion = UIDevice.current.systemVersion
let kDeviceType = "\(UIDevice.current.modelType)"
let kDeviceName = "\(UIDevice.current.modelName)"
let kUUID = UIDevice.current.identifierForVendor!.uuidString
let kBundleID = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String

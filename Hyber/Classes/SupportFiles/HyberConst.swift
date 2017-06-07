//
//  HyberConst.swift
//  Pods
//
//  Created by Taras on 10/21/16.
//
//

import CoreData
extension Hyber {
   public class currentLink {
        static let def = UserDefaults.standard
        public static var current: String = def.object(forKey: "curentUrl") as? String ?? "http://10.0.4.30/"
        public static func mainUrl(url:String) -> String {
            self.def.set(url,forKey: "curentUrl")
            self.def.synchronize()
            self.current = url
            print(self.current)
            return self.current
        }
    }
}
//Device Info
let kOSType = "ios"
let kOSVersion = UIDevice.current.systemVersion
let kDeviceType = "\(UIDevice.current.modelType)"
let kDeviceName = "\(UIDevice.current.modelName)"
let kBundleID = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String

let kHyberClientAPIKey = UserDefaults.standard.string(forKey:"clientApiKey")
let kFCM = UserDefaults.standard.string(forKey: "fcmToken")


///Test server
let kRegUrl = Hyber.currentLink.current + "mobile-api/api/v1/device/registration"
let kUpdateUrl = Hyber.currentLink.current + "mobile-api/api/v1/device/update"
let kSendMsgDr = Hyber.currentLink.current  + "push-dr-receiver/api/v1/message/dr/"
let kGetMsgHistory = Hyber.currentLink.current  + "mobile-api/api/v1/message/history"
let kSendMsgCallback = Hyber.currentLink.current  + "push-callback-receiver/api/v1/message/callback/"
let kDeleteDevice = Hyber.currentLink.current  + "mobile-api/api/v1/device/revoke"
let kGetDeviceInfo = Hyber.currentLink.current  + "mobile-api/api/v1/device/all"


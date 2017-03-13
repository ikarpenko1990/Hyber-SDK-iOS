
import RealmSwift
import SwiftyJSON
import XCTest
@testable import Hyber


class HyberRealmTests: XCTestCase {
    
    
    func testExampleToken() {
        Hyber.saveToken(fcmToken: "123123")
        XCTAssertTrue(true, "Token saved")
    }
    
    func testSaveSessionID() {
        let valid = "97b795ba-ec7c-11e6-b006-92361f002671"
        XCTAssert( valid == "97b795ba-ec7c-11e6-b006-92361f002671", "Valid Session ID")
        DataRealm.session(uuid: valid)
        let date = NSDate()
        let utc = date.toString()
        print(utc)
    }
    
    func testNetworkingMethods() {
        Hyber.LogOut()
        Hyber.getMessageList(completionHandler:{_ in })
        Hyber.getDeviceList(completionHandler:{_ in })
        Hyber.revokeDevice(deviceId: ["",], completionHandler: (completionHandler:{_ in }))
        Hyber.updateDevice()
        Hyber.sentDeliveredStatus(messageId: nil)
    }
    
    func testSaveProfile() {
        let session = ["token": "dsfsfsf"]
        let user = ["userPhone": "380000000000",
                    "userId": "123"]
        let fulfile = ["profile":user,"session":session ]
        let json = JSON(fulfile)
        DataRealm.saveProfile(json: json)
        print("Save profile passed")
    }
    
    func testDevices() {
        let device1 = [
            "osVersion": "8.0",
            "id": "123",
            "deviceType": "phone",
            "deviceName": "Meizu",
            "createdAt": "22-11-1970 12:12",
            "osType": "android",
            "updatedAt": "22-11-1970 18:12"
        ]
        let device2 = ["osVersion": "10.0",
                       "id": "143",
                       "deviceType": "phone",
                       "deviceName": "Meizu",
                       "createdAt": "22-11-1970 12:13",
                       "osType": "ios",
                       "updatedAt": "22-11-1970 18:14"]
        
        let devices = ["devices": [device1, device2]]
        let json = JSON(devices)
        DataRealm.saveDeiveList(json: json)
        print("Save device passed")
    }
    
    func testUpdateDevice() {
            let device = ["deviceId":"1"]
            let json = JSON(device)
            DataRealm.updateDevice(json: json)
            XCTAssertTrue(true, "\(json)")
    }
    
    func testSaveMessage() {
        let msg1 = [
            "messageId": "12345",
            "button": NSNull(),
            "body": "Some text here",
            "image": NSNull(),
            "phone": "1234567890",
            "title": "TestTitle",
            "time": "22-11-1970 14:30",
            "partner": "Incuube"
            ] as [String : Any]
        let msg2 = [
            "messageId": NSNull(),
            "button": NSNull(),
            "body": NSNull(),
            "image": NSNull(),
            "phone": NSNull(),
            "title": NSNull(),
            "time": NSNull(),
            "partner": NSNull()
        ]
        let img = [ "text": "Title button",
                    "url": "http://google.com"
        ]
        let btn = ["image": "http://google.com",
                   "url": "http://google.com"]
        let msg3 = [
            "messageId": "123454",
            "button":btn,
            "body": "Some text here",
            "image":img,
            "phone": "1234567890",
            "title": "TestTitle",
            "time": "22-11-1970 14:35",
            "partner": "Incuube"
            ] as [String : Any]
        
        let msgs = ["messages": [msg1,msg2,msg3]]
        let json = JSON(msgs)
        DataRealm.saveMessages(json: json)
        print("Save messages passed")

    }
    
    func testSaveNotification() {
        let headers = [ "title":"4rwre4r",
                        "body":"43rw3r",]
        let notification = ["notification":headers]
        let img = [ "text": "Title button",
                    "url": "http://google.com"
        ]
        let btn = ["image": "http://google.com",
                   "url": "http://google.com"]
        
        let msg = ["messageId": "12345",
                   "button": btn,
                   "body": "Some text here",
                   "image": img,
                   "phone": "1234567890",
                   "title": "TestTitle",
                   "time": "22-11-1970 14:30",
                   "partner": "Incuube"] as [String : Any]
        let notif = JSON(notification)
        let json = JSON(msg)
        let push = ["aps":notif,"data":json] as [AnyHashable:Any]
        DataRealm.saveNotification(json: json, message: notif)
        Hyber.didReceiveRemoteNotification(userInfo: push)
    }
    
    func testDeleteEntity() {
        Hyber.clearHistory(entity:Session.self)
    }
    
    func testConstants() {
        let model = UIDevice.current.modelType
        let type = UIDevice.current.modelName
        let BundleID = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String
        print("Phone data: \(model), \(type), \(BundleID)")
    }
    
}

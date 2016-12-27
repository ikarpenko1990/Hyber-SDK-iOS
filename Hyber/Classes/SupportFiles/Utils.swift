//
//  HyberExtention.swift
//  Pods
//
//  Created by Taras on 11/8/16.
//
//

import UIKit
import Foundation

extension Date {
    init?(jsonDate: String) {
        let prefix = "/Date("
        let suffix = ")/"
        let scanner = Scanner(string: jsonDate)

        // Check prefix:
        guard scanner.scanString(prefix, into: nil) else { return nil }

        // Read milliseconds part:
        var milliseconds: Int64 = 0
        guard scanner.scanInt64(&milliseconds) else { return nil }
        // Milliseconds to seconds:
        var timeStamp = TimeInterval(milliseconds) / 1000.0

        // Read optional timezone part:
        var timeZoneOffset: Int = 0
        if scanner.scanInt(&timeZoneOffset) {
            let hours = timeZoneOffset / 100
            let minutes = timeZoneOffset % 100
            // Adjust timestamp according to timezone:
            timeStamp += TimeInterval(3600 * hours + 60 * minutes)
        }

        // Check suffix:
        guard scanner.scanString(suffix, into: nil) else { return nil }

        // Success! Create NSDate and return.
        self.init(timeIntervalSince1970: timeStamp)
    }
    


}

extension NSDate {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy"
        return dateFormatter.string(from: self as Date)
    }
}
public extension UIDevice {

    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {
        case "iPod5,1": return "iPod Touch 5"
        case "iPod7,1": return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
        case "iPhone4,1": return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2": return "iPhone 5"
        case "iPhone5,3", "iPhone5,4": return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2": return "iPhone 5s"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone8,4": return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3": return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6": return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
        case "iPad5,3", "iPad5,4": return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7": return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad Mini 3"
        case "iPad5,1", "iPad5,2": return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8": return "iPad Pro"
        case "AppleTV5,3": return "Apple TV"
        case "i386", "x86_64": return "Simulator"
        default: return identifier
        }
    }


    var modelType: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {
        case "iPod5,1": return "phone"
        case "iPod7,1": return "phone"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "phone"
        case "iPhone4,1": return "phone"
        case "iPhone5,1", "iPhone5,2": return "phone"
        case "iPhone5,3", "iPhone5,4": return "phone"
        case "iPhone6,1", "iPhone6,2": return "phone"
        case "iPhone7,2": return "phone"
        case "iPhone7,1": return "phone"
        case "iPhone8,1": return "phone"
        case "iPhone8,2": return "phone"
        case "iPhone9,1", "iPhone9,3": return "phone"
        case "iPhone9,2", "iPhone9,4": return "phone"
        case "iPhone8,4": return "phone"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "tablet"
        case "iPad3,1", "iPad3,2", "iPad3,3": return "tablet"
        case "iPad3,4", "iPad3,5", "iPad3,6": return "tablet"
        case "iPad4,1", "iPad4,2", "iPad4,3": return "tablet"
        case "iPad5,3", "iPad5,4": return "tablet"
        case "iPad2,5", "iPad2,6", "iPad2,7": return "tablet"
        case "iPad4,4", "iPad4,5", "iPad4,6": return "tablet"
        case "iPad4,7", "iPad4,8", "iPad4,9": return "tablet"
        case "iPad5,1", "iPad5,2": return "tablet"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8": return "tablet"
        case "AppleTV5,3": return "tablet"
        case "i386", "x86_64": return "phone"
        default: return identifier
        }
    }

}

extension Bundle {
    class func mainInfoDictionary(key: CFString) -> String? {
        return self.main.infoDictionary?[key as String] as? String
    }
}



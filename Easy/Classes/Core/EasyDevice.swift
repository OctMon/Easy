//
//  EasyDevice.swift
//  Easy
//
//  Created by OctMon on 2018/10/29.
//

import UIKit

public extension EasyApp {
    
    enum DeviceModel: String {
        /*** iPhone ***/
        case iPhone4
        case iPhone4S
        case iPhone5
        case iPhone5C
        case iPhone5S
        case iPhone6
        case iPhone6Plus
        case iPhone6S
        case iPhone6SPlus
        case iPhoneSE
        case iPhone7
        case iPhone7Plus
        case iPhone8
        case iPhone8Plus
        case iPhoneX
        case iPhoneXS
        case iPhoneXS_Max
        case iPhoneXR
        
        /*** iPad ***/
        case iPad1
        case iPad2
        case iPad3
        case iPad4
        case iPad5
        case iPad6
        case iPadAir
        case iPadAir2
        case iPadMini
        case iPadMini2
        case iPadMini3
        case iPadMini4
        case iPadPro9_7Inch
        case iPadPro10_5Inch
        case iPadPro12_9Inch
        
        /*** iPod ***/
        case iPodTouch1Gen
        case iPodTouch2Gen
        case iPodTouch3Gen
        case iPodTouch4Gen
        case iPodTouch5Gen
        case iPodTouch6Gen
        
        /*** simulator ***/
        case simulator
        
        /*** unknown ***/
        case unknown
        
        public var name: String {
            var model = "\(self)"
            if model.hasPrefix("iPhone") {
                model = model.replacingOccurrences(of: "_", with: " ")
            } else if model.hasPrefix("iPad") {
                model = model.replacingOccurrences(of: "_", with: ".")
            }
            return model
        }
    }
    
    enum DeviceType: String {
        case iPhone
        case iPad
        case iPod
        case simulator
        case unknown
    }
    
    enum DeviceSize: Int, Comparable {
        case unknownSize = 0
        /// iPhone 4, 4s, iPod Touch 4th gen.
        case screen3_5Inch
        /// iPhone 5, 5s, 5c, SE, iPod Touch 5-6th gen.
        case screen4Inch
        /// iPhone 6, 6s, 7, 8
        case screen4_7Inch
        /// iPhone 6+, 6s+, 7+, 8+
        case screen5_5Inch
        /// iPhone X, Xs
        case screen5_8Inch
        /// iPhone Xr
        case screen6_1Inch
        /// iPhone Xs Max
        case screen6_5Inch
        /// iPad Mini
        case screen7_9Inch
        /// iPad
        case screen9_7Inch
        /// iPad Pro (10.5-inch)
        case screen10_5Inch
        /// iPad Pro (12.9-inch)
        case screen12_9Inch
    }
    
}

public func <(lhs: EasyApp.DeviceSize, rhs: EasyApp.DeviceSize) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

public func ==(lhs: EasyApp.DeviceSize, rhs: EasyApp.DeviceSize) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

public extension EasyApp {
    
    /// My iPhone
    static let aboutName = UIDevice.current.name
    /// iOS/tvOS/watchOS
    static let systemName = UIDevice.current.systemName
    /// 12.0
    static let systemVersion = UIDevice.current.systemVersion
    /// 0.0 - 1.0
    static let batteryLevel = UIDevice.current.batteryLevel
    
    static var deviceMachine: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    static var deviceModel: EasyApp.DeviceModel {
        switch deviceMachine {
            /*** iPhone ***/
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":
            return .iPhone4
        case "iPhone4,1", "iPhone4,2", "iPhone4,3":
            return .iPhone4S
        case "iPhone5,1", "iPhone5,2":
            return .iPhone5
        case "iPhone5,3", "iPhone5,4":
            return .iPhone5C
        case "iPhone6,1", "iPhone6,2":
            return .iPhone5S
        case "iPhone7,2":
            return .iPhone6
        case "iPhone7,1":
            return .iPhone6Plus
        case "iPhone8,1":
            return .iPhone6S
        case "iPhone8,2":
            return .iPhone6SPlus
        case "iPhone8,3", "iPhone8,4":
            return .iPhoneSE
        case "iPhone9,1", "iPhone9,3":
            return .iPhone7
        case "iPhone9,2", "iPhone9,4":
            return .iPhone7Plus
        case "iPhone10,1", "iPhone10,4":
            return .iPhone8
        case "iPhone10,2", "iPhone10,5":
            return .iPhone8Plus
        case "iPhone10,3", "iPhone10,6":
            return .iPhoneX
        case "iPhone11,2":
            return .iPhoneXS
        case "iPhone11,4", "iPhone11,6":
            return .iPhoneXS_Max
        case "iPhone11,8":
            return .iPhoneXR
            
            /*** iPad ***/
        case "iPad1,1", "iPad1,2":
            return .iPad1
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return .iPad2
        case "iPad3,1", "iPad3,2", "iPad3,3":
            return .iPad3
        case "iPad3,4", "iPad3,5", "iPad3,6":
            return .iPad4
        case "iPad6,11", "iPad6,12":
            return .iPad5
        case "iPad7,5", "iPad 7,6":
            return .iPad6
        case "iPad4,1", "iPad4,2", "iPad4,3":
            return .iPadAir
        case "iPad5,3", "iPad5,4":
            return .iPadAir2
        case "iPad2,5", "iPad2,6", "iPad2,7":
            return .iPadMini
        case "iPad4,4", "iPad4,5", "iPad4,6":
            return .iPadMini2
        case "iPad4,7", "iPad4,8", "iPad4,9":
            return .iPadMini3
        case "iPad5,1", "iPad5,2":
            return .iPadMini4
        case "iPad6,7", "iPad6,8", "iPad7,1", "iPad7,2":
            return .iPadPro12_9Inch
        case "iPad7,3", "iPad7,4":
            return .iPadPro10_5Inch
        case "iPad6,3", "iPad6,4":
            return .iPadPro9_7Inch
            
            /*** iPod ***/
        case "iPod1,1":
            return .iPodTouch1Gen
        case "iPod2,1":
            return .iPodTouch2Gen
        case "iPod3,1":
            return .iPodTouch3Gen
        case "iPod4,1":
            return .iPodTouch4Gen
        case "iPod5,1":
            return .iPodTouch5Gen
        case "iPod7,1":
            return .iPodTouch6Gen
            
            /*** Simulator ***/
        case "i386", "x86_64":
            return .simulator
            
        default:
            return .unknown
        }
    }
    
    static var deviceType: EasyApp.DeviceType {
        let model = deviceMachine
        if model.contains("iPhone") {
            return .iPhone
        } else if model.contains("iPad") {
            return .iPad
        } else if model.contains("iPod") {
            return .iPod
        } else if model == "i386" || model == "x86_64" {
            return .simulator
        } else {
            return .unknown
        }
    }
    
    static var deviceSize: EasyApp.DeviceSize {
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        let screenHeight = max(w, h)
        
        switch screenHeight {
        case 480:
            return .screen3_5Inch
        case 568:
            return .screen4Inch
        case 667:
            return UIScreen.main.scale == 3.0 ? .screen5_5Inch : .screen4_7Inch
        case 736:
            return .screen5_5Inch
        case 812:
            return .screen5_8Inch
        case 896:
            return UIScreen.main.scale == 3.0 ? .screen6_5Inch : .screen6_1Inch
        case 1024:
            switch deviceModel {
            case .iPadMini,.iPadMini2,.iPadMini3,.iPadMini4:
                return .screen7_9Inch
            case .iPadPro10_5Inch:
                return .screen10_5Inch
            default:
                return .screen9_7Inch
            }
        case 1112:
            return .screen10_5Inch
        case 1366:
            return .screen12_9Inch
        default:
            return .unknownSize
        }
    }
    
    static let isPad = deviceType == .iPad
    static let isPhone = deviceType == .iPhone
    static let isPod = deviceType == .iPod
    static let isSimulator = deviceType == .simulator
    static let isFaceIDCapableDevices = deviceSize == .screen5_8Inch || deviceSize == .screen6_1Inch || deviceSize == .screen6_5Inch
    static let safeBottomEdge = CGFloat(isFaceIDCapableDevices ? 34 : 0)
    
}

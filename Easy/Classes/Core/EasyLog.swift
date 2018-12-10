//
//  EasyLog.swift
//  Easy
//
//  Created by OctMon on 2018/9/28.
//

import Foundation

public extension Easy {
    typealias Log = EasyLog
}

public struct EasyLog {
    
    private init() {}
    
    private static var defaultLogLKey: String {
        return "easyDefaultLog".md5
    }
    
}

public extension EasyLog {
    
    static func debug<T>(_ message: T, file: String = #file, method: String = #function, lineNumber: Int = #line) {
        #if DEBUG || BETA
        let fileName = (file as NSString).lastPathComponent
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.string(from: now)
        let timeStamp = now.timeIntervalSince1970
        let millisecond = CLongLong(round(timeStamp * 1000))
        print("\(date).\(String(format: "%.3d", millisecond % CLongLong(timeStamp))) [debug] [\(fileName):\(lineNumber)] \(method) > \(message)")
        #endif
    }
    
    static func print<T>(_ message: T) {
        #if DEBUG || BETA
        Swift.print(message)
        record(message)
        #endif
    }
    
    #if DEBUG || BETA
    internal static var log: String? {
        return EasyApp.userDefaults.string(forKey: defaultLogLKey)
    }
    
    internal static var logHandler: ((String) -> Void)?
    
    internal static func clear() {
        EasyApp.userDefaults.set(nil, forKey: defaultLogLKey)
    }
    
    private static func record<T>(_ message: T) {
        autoreleasepool { () in
            var log = "\(message)\n"
            if let string = EasyLog.log {
                log = string + log
            }
            EasyApp.userDefaults.set(log, forKey: defaultLogLKey)
            EasyApp.userDefaults.string(forKey: defaultLogLKey)
            
            logHandler?(log)
        }
    }
    #endif
}

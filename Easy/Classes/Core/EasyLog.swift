//
//  EasyLog.swift
//  Easy
//
//  Created by OctMon on 2018/9/28.
//

import Foundation

public struct EasyLog {
    
    private init() {}
    
    private static var defaultLogLKey: String {
        return "easyDefaultLog".md5
    }
    
}

public extension EasyLog {
    
    static var log: String? {
        return Easy.userDefaults.string(forKey: defaultLogLKey)
    }
    
    static var logHandler: ((String) -> Void)?
    
    static func clear() {
        Easy.userDefaults.set(nil, forKey: defaultLogLKey)
    }
    
    static func debug<T>(_ message: T, file: String = #file, method: String = #function, lineNumber: Int = #line) {
        #if DEBUG
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
        #if DEBUG
        Swift.print(message)
        record(message)
        #endif
    }
    
    #if DEBUG
    private static func record<T>(_ message: T) {
        autoreleasepool { () in
            var log = "\(message)\n"
            if let string = EasyLog.log {
                log = string + log
            }
            Easy.userDefaults.set(log, forKey: defaultLogLKey)
            Easy.userDefaults.string(forKey: defaultLogLKey)
            
            logHandler?(log)
        }
    }
    #endif
}

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
    
    public static let logURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("log.txt")
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
        guard let fileURL = EasyLog.logURL, let data = try? Data(contentsOf: fileURL) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    internal static var logHandler: ((String) -> Void)?
    
    internal static func clear() {
        guard let fileURL = EasyLog.logURL else { return }
        try? FileManager.default.removeItem(atPath: fileURL.path)
    }
    
    private static func record<T>(_ message: T) {
        autoreleasepool { () in
            var log = "\(message)\n"
            appendText(string: log)
        }
    }
    
    /// 在文件末尾追加新内容
    private static func appendText(string: String) {
        do {
            guard let fileURL = EasyLog.logURL else { return }
            // 如果文件不存在则新建一个
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                FileManager.default.createFile(atPath: fileURL.path, contents: nil)
            }
             
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            let stringToWrite = "\n" + string
             
            // 写入到文件
            if let data = stringToWrite.data(using: .utf8) {
                defer {
                    fileHandle.closeFile()
                }
                // 找到末尾位置并添加
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                if let log = log {
                    logHandler?(log)
                }
            }
        } catch let error  {
            EasyLog.debug("failed to append: \(error)")
        }
    }
    #endif
}

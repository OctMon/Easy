//
//  EasyConfig.swift
//  Easy
//
//  Created by OctMon on 2018/10/16.
//

import Foundation

public struct EasyConfig {
    
    public init() { }
    
    public struct BaseURL {
        public var global: String?
        public var release = ""
        public var test = ""
        public var list = [String]()
        public var addition: [String: [String: String]]?
        public var alias: String = ""
        
        public var currentBaseURL: String {
            if let global = global {
                return global
            }
            if EasyApp.isBeta {
                if let url = UserDefaults.standard.string(forKey: defaultCustomBaseURLKey), !url.isEmpty {
                    return url
                }
                return test.isEmpty ? release : test
            }
            return release.isEmpty ? test : release
        }
        
        public func currentAddition(key: String) -> String? {
            if let global = global {
                return addition?[global]?[key]
            }
            if EasyApp.isBeta {
                if let url = UserDefaults.standard.string(forKey: defaultCustomBaseURLKey), !url.isEmpty {
                    return addition?[url]?[key] ?? addition?[test]?[key]
                }
                return addition?[test]?[key]
            }
            return addition?[release]?[key]
        }
    }
    
    public struct Key {
        public var code = ["code"]
        public var data = ["data"]
        public var msg = ["message"]
        public var total = ["total"]
        public var list = ["data", "list"]
        public var page = "page"
        public var size = "size"
    }
    
    public struct Code {
        public var success = 0
        /// HTTP status code validate
        public var successStatusCode = 200
        public var empty: Int?
        public var tokenExpired: Int?
        public var forceUpdate: Int?
        public var unknown = -990909
        
        /// Successfully only valid with HTTP status code.
        public var onlyValidWithHTTPstatusCode = false
        /// Validates that the response has a status code in the specified sequence.
        public var acceptableStatusCodes: Array? = Array(200..<300)
    }
    
    public struct Other {
        public var timeout: TimeInterval = 10
    }
    
    public var url = BaseURL()
    public var key = Key()
    public var code = Code()
    public var other = Other()
}

extension EasyConfig.BaseURL {
    
    var defaultCustomBaseURLKey: String {
        return "EasyDefaultCustomBaseURL_\(alias.md5)".md5
    }
    
}

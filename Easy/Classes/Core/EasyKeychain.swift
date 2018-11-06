//
//  EasyKeychain.swift
//  Easy
//
//  Created by OctMon on 2018/9/29.
//

import UIKit

public extension Easy {
    typealias Keychain = EasyKeychain
}

public struct EasyKeychain {
    
    private init() {}
    
    private static func searchInfoInKeyChain(service: String) -> [CFString: Any] {
        return [kSecClass: kSecClassGenericPassword, kSecAttrService: service, kSecAttrAccount: service, kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock]
    }
    
}

public extension EasyKeychain {
    
    /// 增
    @discardableResult
    static func save(service: String, value: Any) -> Bool {
        var keyChain = self.searchInfoInKeyChain(service: service)
        if SecItemCopyMatching(keyChain as CFDictionary, nil) == noErr {
            SecItemDelete(keyChain as CFDictionary)
        }
        keyChain[kSecValueData] = NSKeyedArchiver.archivedData(withRootObject: value)
        if SecItemAdd(keyChain as CFDictionary, nil) == noErr {
            EasyLog.debug("EasyKeychain save: \(service)->\(value) saved.")
            return true
        } else {
            EasyLog.debug("EasyKeychain save: \(service)->\(value) failed.")
            return false
        }
    }
    
    /// 删
    @discardableResult
    static func delete(service: String) -> Bool {
        let keyChain = self.searchInfoInKeyChain(service: service)
        if SecItemDelete(keyChain as CFDictionary) == noErr {
            EasyLog.debug("EasyKeychain delete: \(service) deleted.")
            return true
        } else {
            EasyLog.debug("EasyKeychain delete: \(service) failed.")
            return false
        }
    }
    
    /// 改
    @discardableResult
    static func update(service: String, value: Any) -> Bool {
        let keyChain = self.searchInfoInKeyChain(service: service)
        let changes = [kSecValueData: NSKeyedArchiver.archivedData(withRootObject: value)]
        if SecItemUpdate(keyChain as CFDictionary, changes as CFDictionary) == noErr {
            EasyLog.debug("EasyKeychain update: \(service)->\(value) updated.")
            return true
        } else {
            EasyLog.debug("EasyKeychain update: \(service)->\(value) failed.")
            return false
        }
    }
    
    /// 查
    static func get(service: String) -> Any? {
        var keyChain = self.searchInfoInKeyChain(service: service)
        keyChain[kSecReturnData] = kCFBooleanTrue
        keyChain[kSecMatchLimit] = kSecMatchLimitOne
        var any: Any?
        var keyData: CFTypeRef?
        if SecItemCopyMatching(keyChain as CFDictionary, &keyData) == noErr {
            guard let keyData = keyData as? Data else { return nil }
            any = NSKeyedUnarchiver.unarchiveObject(with: keyData)
        } else {
            EasyLog.debug("EasyKeychain load: \(service) item not founded.")
        }
        return any
    }
    
    static func getUUID(service: String) -> String? {
        let uuid = get(service: service) as? String
        if uuid == nil {
            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                save(service: service, value: uuid)
                return uuid
            }
        }
        return uuid
    }
    
}

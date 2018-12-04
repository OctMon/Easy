//
//  EasyRSA.swift
//  Easy
//
//  Created by OctMon on 2018/11/15.
//

import Foundation
import SwiftyRSA

public extension String {
    
    func encryptRSA(using encoding: String.Encoding = .utf8, padding: Padding = .PKCS1, publicKey: String) -> EncryptedMessage? {
        guard let publicKey = try? PublicKey(pemEncoded: publicKey) else { return nil }
        guard let clear = try? ClearMessage(string: self, using: encoding) else { return nil }
        guard let encrypted = try? clear.encrypted(with: publicKey, padding: padding) else { return nil }
        return encrypted
    }
    
    func encryptRSA_toString(using encoding: String.Encoding = .utf8, padding: Padding = .PKCS1, publicKey: String) -> String? {
        return encryptRSA(using: encoding, padding: padding, publicKey: publicKey)?.base64String
    }
    
    func decryptRSA(padding: Padding = .PKCS1, privateKey: String) -> ClearMessage? {
        guard let privateKey = try? PrivateKey(pemEncoded: privateKey) else { return nil }
        guard let encrypted = try? EncryptedMessage(base64Encoded: self) else { return nil }
        guard let clear = try? encrypted.decrypted(with: privateKey, padding: padding) else { return nil }
        return clear
    }
    
    func decryptRSA_toString(using encoding: String.Encoding = .utf8, padding: Padding = .PKCS1, privateKey: String) -> String {
        guard let string = try? decryptRSA(padding: padding, privateKey: privateKey)?.string(encoding: encoding) else { return "" }
        return string ?? ""
    }
    
    func decryptRSA_toBase64(padding: Padding = .PKCS1, privateKey: String) -> String {
        return decryptRSA(padding: padding, privateKey: privateKey)?.base64String ?? ""
    }
    
}

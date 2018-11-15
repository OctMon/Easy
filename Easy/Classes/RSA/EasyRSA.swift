//
//  EasyRSA.swift
//  Easy
//
//  Created by OctMon on 2018/11/15.
//

import Foundation
import SwiftyRSA

public extension Easy {
    typealias RSA = EasyRSA
}

public struct EasyRSA {
    var publicKey = ""
    var privateKey = ""
    
    static var shared = EasyRSA()
    
    private init() { }
    
    public static func set(publicKey: String, privateKey: String) {
        shared.publicKey = publicKey
        shared.privateKey = privateKey
    }
}

public extension String {
    
    func encryptRSA(using encoding: String.Encoding = .utf8, padding: Padding = .PKCS1) -> EncryptedMessage? {
        guard let publicKey = try? PublicKey(pemEncoded: EasyRSA.shared.publicKey) else { return nil }
        guard let clear = try? ClearMessage(string: self, using: encoding) else { return nil }
        guard let encrypted = try? clear.encrypted(with: publicKey, padding: padding) else { return nil }
        return encrypted
    }
    
    func encryptRSA_toString(using encoding: String.Encoding = .utf8, padding: Padding = .PKCS1) -> String? {
        return encryptRSA(using: encoding, padding: padding)?.base64String
    }
    
    func decryptRSA(padding: Padding = .PKCS1) -> ClearMessage? {
        guard let privateKey = try? PrivateKey(pemEncoded: EasyRSA.shared.privateKey) else { return nil }
        guard let encrypted = try? EncryptedMessage(base64Encoded: self) else { return nil }
        guard let clear = try? encrypted.decrypted(with: privateKey, padding: padding) else { return nil }
        return clear
    }
    
    func decryptRSA_toString(using encoding: String.Encoding = .utf8, padding: Padding = .PKCS1) -> String {
        guard let string = try? decryptRSA(padding: padding)?.string(encoding: encoding) else { return "" }
        return string ?? ""
    }
    
    func decryptRSA_toBase64(padding: Padding = .PKCS1) -> String {
        return decryptRSA(padding: padding)?.base64String ?? ""
    }
    
}

//
//  EasyCrypto.swift
//  Easy
//
//  Created by OctMon on 2018/9/28.
//

import Foundation
import CommonCrypto

public enum EasyCryptoAlgorithm {
    case AES, AES128, DES, DES3, CAST, RC2, RC4, Blowfish
    
    var algorithm: CCAlgorithm {
        var result: UInt32 = 0
        switch self {
        case .AES:
            result = UInt32(kCCAlgorithmAES)
        case .AES128:
            result = UInt32(kCCAlgorithmAES128)
        case .DES:
            result = UInt32(kCCAlgorithmDES)
        case .DES3:
            result = UInt32(kCCAlgorithm3DES)
        case .CAST:
            result = UInt32(kCCAlgorithmCAST)
        case .RC2:
            result = UInt32(kCCAlgorithmRC2)
        case .RC4:
            result = UInt32(kCCAlgorithmRC4)
        case .Blowfish:
            result = UInt32(kCCAlgorithmBlowfish)
        }
        return CCAlgorithm(result)
    }
    
    var keyLength: Int {
        var result: Int = 0
        switch self {
        case .AES:
            result = kCCKeySizeAES128
        case .AES128:
            result = kCCKeySizeAES256
        case .DES:
            result = kCCKeySizeDES
        case .DES3:
            result = kCCKeySize3DES
        case .CAST:
            result = kCCKeySizeMaxCAST
        case .RC2:
            result = kCCKeySizeMaxRC2
        case .RC4:
            result = kCCKeySizeMaxRC4
        case .Blowfish:
            result = kCCKeySizeMaxBlowfish
        }
        return Int(result)
    }
    
    var cryptLength: Int {
        var result: Int = 0
        switch self {
        case .AES:
            result = kCCKeySizeAES128
        case .AES128:
            result = kCCBlockSizeAES128
        case .DES:
            result = kCCBlockSizeDES
        case .DES3:
            result = kCCBlockSize3DES
        case .CAST:
            result = kCCBlockSizeCAST
        case .RC2:
            result = kCCBlockSizeRC2
        case .RC4:
            result = kCCBlockSizeRC2
        case .Blowfish:
            result = kCCBlockSizeBlowfish
        }
        return Int(result)
    }
}

public extension String {
    
    /// 加密 iOS、后台、Android 三个一致的DES加密 http://www.jianshu.com/p/630e5899582d
    func encryptDES(key: String, iv: String = "01234567") -> String? {
        return data(using: .utf8)?.encrypt(algorithm: .DES, options: CCOptions(kCCOptionPKCS7Padding), key: key, iv: iv)?.base64EncodedString()
    }
    
    /// 加密 iOS、后台、Android 三个一致的DES加密 http://www.jianshu.com/p/630e5899582d
    func decryptDES(key: String, iv: String = "01234567") -> String? {
        guard let data = Data(base64Encoded: self)?.decrypt(algorithm: .DES, options: CCOptions(kCCOptionPKCS7Padding), key: key, iv: iv) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// 加密
    func encryptAlgorithm(_ algorithm: EasyCryptoAlgorithm, options: CCOptions = CCOptions(kCCOptionECBMode + kCCOptionPKCS7Padding), key: String, iv: String = "") -> String? {
        return data(using: .utf8)?.encrypt(algorithm: algorithm, options: options, key: key, iv: iv)?.base64EncodedString()
    }
    
    /// 解密
    func decryptAlgorithm(_ algorithm: EasyCryptoAlgorithm, options: CCOptions = CCOptions(kCCOptionECBMode + kCCOptionPKCS7Padding), key: String, iv: String = "") -> String? {
        guard let data = Data(base64Encoded: self)?.decrypt(algorithm: algorithm, options: options, key: key, iv: iv) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
}

public extension Data {
    
    /// 加密
    func encrypt(algorithm: EasyCryptoAlgorithm = .DES, options: CCOptions = CCOptions(kCCOptionPKCS7Padding), key: String, iv: String) -> Data? {
        guard let key = key.data(using: .utf8) else { return nil }
        return crypt(operation: CCOperation(kCCEncrypt), algorithm: algorithm, options: options, key: key, iv: iv)
    }
    
    /// 解密
    func decrypt(algorithm: EasyCryptoAlgorithm = .DES, options: CCOptions = CCOptions(kCCOptionPKCS7Padding), key: String, iv: String) -> Data? {
        guard let key = key.data(using: .utf8) else { return nil }
        return crypt(operation: CCOperation(kCCDecrypt), algorithm: algorithm, options: options, key: key, iv: iv)
    }
    
    private func crypt(operation: CCOperation, algorithm: EasyCryptoAlgorithm, options: CCOptions, key: Data, iv: String) -> Data? {
        let keyLength = Int(algorithm.keyLength)
        let dataLength = self.count
        let cryptLength = Int(dataLength+algorithm.cryptLength)
        let cryptPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: cryptLength)
        let algoritm = CCAlgorithm(algorithm.algorithm)
        let numBytesEncrypted = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        numBytesEncrypted.initialize(to: 0)
        
        var keyBytes: UnsafePointer<Int8>?
        key.withUnsafeBytes { (bytes: UnsafePointer<Int8>) -> Void in
            keyBytes = bytes
        }
        
        var dataBytes: UnsafePointer<Int8>?
        self.withUnsafeBytes { (bytes: UnsafePointer<CChar>) -> Void in
            dataBytes = bytes
        }
        
        let cryptStatus = CCCrypt(operation, algoritm, options, keyBytes, keyLength, iv, dataBytes, dataLength, cryptPointer, cryptLength, numBytesEncrypted)
        
        if CCStatus(cryptStatus) == CCStatus(kCCSuccess) {
            let len = Int(numBytesEncrypted.pointee)
            let data = Data(bytes: cryptPointer, count: len)
            numBytesEncrypted.deallocate()
            return data
        } else {
            numBytesEncrypted.deallocate()
            cryptPointer.deallocate()
            return nil
        }
    }

}

public extension String {
    
    var md5: String {
        if let data = self.data(using: .utf8, allowLossyConversion: true) {
            let message = data.withUnsafeBytes { bytes -> [UInt8] in
                return Array(UnsafeBufferPointer(start: bytes, count: data.count))
            }
            let MD5Calculator = MD5(message)
            let MD5Data = MD5Calculator.calculate()
            
            let MD5String = NSMutableString()
            for c in MD5Data {
                MD5String.appendFormat("%02x", c)
            }
            return MD5String as String
        } else {
            return self
        }
    }
    
}


/** array of bytes, little-endian representation */
private func arrayOfBytes<T>(_ value: T, length: Int? = nil) -> [UInt8] {
    let totalBytes = length ?? (MemoryLayout<T>.size * 8)
    
    let valuePointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    valuePointer.pointee = value
    
    let bytes = valuePointer.withMemoryRebound(to: UInt8.self, capacity: totalBytes) { (bytesPointer) -> [UInt8] in
        var bytes = [UInt8](repeating: 0, count: totalBytes)
        for j in 0..<min(MemoryLayout<T>.size, totalBytes) {
            bytes[totalBytes - 1 - j] = (bytesPointer + j).pointee
        }
        return bytes
    }
    
    #if swift(>=4.1)
    valuePointer.deinitialize(count: 1)
    valuePointer.deallocate()
    #else
    valuePointer.deinitialize()
    valuePointer.deallocate(capacity: 1)
    #endif
    
    return bytes
}

private extension Int {
    /** Array of bytes with optional padding (little-endian) */
    func bytes(_ totalBytes: Int = MemoryLayout<Int>.size) -> [UInt8] {
        return arrayOfBytes(self, length: totalBytes)
    }
    
}

private extension NSMutableData {
    
    /** Convenient way to append bytes */
    @objc func appendBytes(_ arrayOfBytes: [UInt8]) {
        append(arrayOfBytes, length: arrayOfBytes.count)
    }
    
}

private protocol HashProtocol {
    var message: Array<UInt8> { get }
    
    /** Common part for hash calculation. Prepare header data. */
    func prepare(_ len: Int) -> Array<UInt8>
}

private extension HashProtocol {
    
    func prepare(_ len: Int) -> Array<UInt8> {
        var tmpMessage = message
        
        // Step 1. Append Padding Bits
        tmpMessage.append(0x80) // append one bit (UInt8 with one bit) to message
        
        // append "0" bit until message length in bits ≡ 448 (mod 512)
        var msgLength = tmpMessage.count
        var counter = 0
        
        while msgLength % len != (len - 8) {
            counter += 1
            msgLength += 1
        }
        
        tmpMessage += Array<UInt8>(repeating: 0, count: counter)
        return tmpMessage
    }
}

private func toUInt32Array(_ slice: ArraySlice<UInt8>) -> Array<UInt32> {
    var result = Array<UInt32>()
    result.reserveCapacity(16)
    
    for idx in stride(from: slice.startIndex, to: slice.endIndex, by: MemoryLayout<UInt32>.size) {
        let d0 = UInt32(slice[idx.advanced(by: 3)]) << 24
        let d1 = UInt32(slice[idx.advanced(by: 2)]) << 16
        let d2 = UInt32(slice[idx.advanced(by: 1)]) << 8
        let d3 = UInt32(slice[idx])
        let val: UInt32 = d0 | d1 | d2 | d3
        
        result.append(val)
    }
    return result
}

private struct BytesIterator: IteratorProtocol {
    
    let chunkSize: Int
    let data: [UInt8]
    
    init(chunkSize: Int, data: [UInt8]) {
        self.chunkSize = chunkSize
        self.data = data
    }
    
    var offset = 0
    
    mutating func next() -> ArraySlice<UInt8>? {
        let end = min(chunkSize, data.count - offset)
        let result = data[offset..<offset + end]
        offset += result.count
        return result.count > 0 ? result : nil
    }
}

private struct BytesSequence: Sequence {
    let chunkSize: Int
    let data: [UInt8]
    
    func makeIterator() -> BytesIterator {
        return BytesIterator(chunkSize: chunkSize, data: data)
    }
}

private func rotateLeft(_ value: UInt32, bits: UInt32) -> UInt32 {
    return ((value << bits) & 0xFFFFFFFF) | (value >> (32 - bits))
}

private class MD5: HashProtocol {
    
    static let size = 16 // 128 / 8
    let message: [UInt8]
    
    init (_ message: [UInt8]) {
        self.message = message
    }
    
    /** specifies the per-round shift amounts */
    private let shifts: [UInt32] = [7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
                                    5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
                                    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
                                    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21]
    
    /** binary integer part of the sines of integers (Radians) */
    private let sines: [UInt32] = [0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
                                   0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
                                   0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
                                   0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
                                   0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
                                   0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
                                   0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
                                   0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
                                   0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
                                   0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
                                   0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x4881d05,
                                   0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
                                   0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
                                   0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
                                   0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
                                   0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391]
    
    private let hashes: [UInt32] = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476]
    
    func calculate() -> [UInt8] {
        var tmpMessage = prepare(64)
        tmpMessage.reserveCapacity(tmpMessage.count + 4)
        
        // hash values
        var hh = hashes
        
        // Step 2. Append Length a 64-bit representation of lengthInBits
        let lengthInBits = (message.count * 8)
        let lengthBytes = lengthInBits.bytes(64 / 8)
        tmpMessage += lengthBytes.reversed()
        
        // Process the message in successive 512-bit chunks:
        let chunkSizeBytes = 512 / 8 // 64
        
        for chunk in BytesSequence(chunkSize: chunkSizeBytes, data: tmpMessage) {
            // break chunk into sixteen 32-bit words M[j], 0 ≤ j ≤ 15
            var M = toUInt32Array(chunk)
            assert(M.count == 16, "Invalid array")
            
            // Initialize hash value for this chunk:
            var A: UInt32 = hh[0]
            var B: UInt32 = hh[1]
            var C: UInt32 = hh[2]
            var D: UInt32 = hh[3]
            
            var dTemp: UInt32 = 0
            
            // Main loop
            for j in 0 ..< sines.count {
                var g = 0
                var F: UInt32 = 0
                
                switch j {
                case 0...15:
                    F = (B & C) | ((~B) & D)
                    g = j
                    break
                case 16...31:
                    F = (D & B) | (~D & C)
                    g = (5 * j + 1) % 16
                    break
                case 32...47:
                    F = B ^ C ^ D
                    g = (3 * j + 5) % 16
                    break
                case 48...63:
                    F = C ^ (B | (~D))
                    g = (7 * j) % 16
                    break
                default:
                    break
                }
                dTemp = D
                D = C
                C = B
                B = B &+ rotateLeft((A &+ F &+ sines[j] &+ M[g]), bits: shifts[j])
                A = dTemp
            }
            
            hh[0] = hh[0] &+ A
            hh[1] = hh[1] &+ B
            hh[2] = hh[2] &+ C
            hh[3] = hh[3] &+ D
        }
        
        var result = [UInt8]()
        result.reserveCapacity(hh.count / 4)
        
        hh.forEach {
            let itemLE = $0.littleEndian
            result += [UInt8(itemLE & 0xff), UInt8((itemLE >> 8) & 0xff), UInt8((itemLE >> 16) & 0xff), UInt8((itemLE >> 24) & 0xff)]
        }
        return result
    }
}

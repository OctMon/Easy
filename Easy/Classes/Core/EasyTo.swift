//
//  EasyTo.swift
//  Easy
//
//  Created by OctMon on 2018/9/28.
//

import UIKit

public extension NSObject {
    
    var toDeinit: String {
        return ("\(type(of: self))♻️deinit")
    }
    
    var toString: String {
        return String(describing: type(of: self))
    }
    
    static var toString: String {
        return String(describing: self)
    }

}

public extension Optional {
    
    /// 强转为Int类型
    var toInt: Int? {
        return (self as? Int) ?? toString?.toInt
    }
    
    /// 强转为Int类型 失败为0
    var toIntValue: Int {
        return toInt ?? 0
    }
    
    /// 强转为Bool类型
    var toBoolValue: Bool {
        guard let value = self else {
            return false
        }
        return "\(value)".toBoolValue
    }
    
    /// 强转为String类型
    var toString: String? {
        return (self as? String) ?? NumberFormatter().string(for: self)
    }
    
    /// 强转为String类型 失败为""
    var toStringValue: String {
        return toString ?? ""
    }
    
    /// 强转为Array类型
    var toArray: [EasyParameters]? {
        return self as? [EasyParameters]
    }
    
    /// 强转为Array类型 失败为[]
    var toArrayValue: [EasyParameters] {
        return toArray ?? []
    }
    
    /// 强转为EasyParameters类型
    var toParameters: EasyParameters? {
        if let dictionary = self as? EasyParameters {
            return dictionary
        }
        return nil
    }
    
    /// 强转为EasyParameters类型
    var toParametersValue: EasyParameters {
        return toParameters ?? [:]
    }

}

public extension Bool {
    
    var toInt: Int {
        return self ? 1 : 0
    }
    
    var toStringValue: String {
        return self ? "1" : "0"
    }

}

public extension Int {
    
    var toString: String {
        return String(self)
    }
    
    var toDouble: Double {
        return Double(self)
    }
    
    var toFloat: Float {
        return Float(self)
    }
    
    var toCGFloat: CGFloat {
        return CGFloat(self)
    }
    var toColor: UIColor {
        return .hex(self)
    }

}

public extension Double {
    
    var toString: String {
        return String(self)
    }
    
    var toInt: Int {
        return Int(self)
    }
    
    var toDate: Date {
        return Date(timeIntervalSince1970: self / 1000)
    }
}

public extension Array {
    
    var toAny: [Any] {
        return self
    }
    
}

public extension CGSize {
    
    var toRect: CGRect {
        return CGRect(x: 0, y: 0, width: width, height: height)
    }

}

public extension String {
    
    var toFloat: Float? {
        if let num = NumberFormatter().number(from: self) {
            return num.floatValue
        }
        return nil
    }
    
    var toFloatValue: Float {
        return toFloat ?? 0
    }
    
    var toDouble: Double? {
        if let num = NumberFormatter().number(from: self) {
            return num.doubleValue
        }
        return nil
    }
    
    var toDoubleValue: Double {
        return toDouble ?? 0.0
    }
    
    var toInt: Int? {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        }
        return nil
    }
    
    var toIntValue: Int {
        return toInt ?? 0
    }
    
    var toBoolValue: Bool {
        return ["true", "y", "t", "yes", "1"].contains { self.caseInsensitiveCompare($0) == .orderedSame }
    }
    
    /// Date object from "yyyy-MM-dd" formatted string
    var toDate: Date? {
        let lowercased = trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: lowercased)
    }

    /// Date object from "yyyy-MM-dd HH:mm:ss" formatted string.
    var toDateTime: Date? {
        let lowercased = trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: lowercased)
    }
    
    var toJson: Any? {
        if let data = data(using: String.Encoding.utf8) {
            let json = try? JSONSerialization.jsonObject(with: data)
            if let json = json {
                return json
            }
        }
        return nil
    }
    
    var toBase64EncodedData: Data? {
        return data(using: .utf8)
    }
    
    var toBase64Encoded: String? {
        return toBase64EncodedData?.base64EncodedString()
    }
    
    var toBase64Decoded: String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    var toBase64Image: UIImage? {
        guard let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else { return nil }
        return UIImage(data: data)
    }
    
    var toURL: URL? {
        return URL(string: self)
    }
    
    var toURLValue: URL {
        return toURL!
    }
    
    var toURLRequest: URLRequest? {
        return toURL.and(then: { URLRequest(url: $0) })
    }

    var toURLRequestValue: URLRequest {
        return toURLRequest!
    }
    
    
    var toColor: UIColor {
        return .hex(self)
    }
    
    var toURLParameters: [String: Any]? {
        guard let urlComponents = URLComponents(string: self), let queryItems = urlComponents.queryItems else { return nil }
        var parameters = [String: Any]()
        queryItems.forEach({ (item) in
            if let existValue = parameters[item.name], let value = item.value {
                if var existValue = existValue as? [Any] {
                    existValue.append(value)
                } else {
                    parameters[item.name] = [existValue, value]
                }
            } else {
                parameters[item.name] = item.value
            }
        })
        return parameters
    }
    
    func toURL(_ parameters: EasyParameters? = nil) -> URL? {
        guard let parameters = parameters else { return URL(string: self) }
        guard let url = URL(string: self) else { return nil }
        var queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            if let value = value as? String {
                queryItems.append(URLQueryItem(name: key, value: value))
            } else if let value = value as? NSNumber {
                queryItems.append(URLQueryItem(name: key, value: value.stringValue))
            }
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false) // URLComponents(string:self.absoluteString)
        components?.queryItems = queryItems
        return components?.url
    }
    
}

public extension Date {
    
    /**
     G: 公元时代，例如AD公元
     yy:年的后2位
     yyyy:完整年
     MM:月，显示为1-12
     MMM:月，显示为英文月份简写,如 Jan
     MMMM:月，显示为英文月份全称，如 Janualy
     dd:日，2位数表示，如02
     d:日，1-2位显示，如 2
     EEE:简写星期几，如Sun
     EEEE:全写星期几，如Sunday
     aa:上下午，AM/PM
     H:时，24小时制，0-23
     K：时，12小时制，0-11
     m:分，1-2位
     mm:分，2位
     s:秒，1-2位
     ss:秒，2位
     S:毫秒
     */
    func toString(_ dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
}

public extension Data {
    
    var toBase64DecodeValue: String {
        return toBase64Decode ?? ""
    }
    
    var toBase64Decode: String? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters), let string = String(data: data, encoding: .utf8) {
            return string
        }
        return nil
    }
    
    var toJsonString: String? {
        if let json = try? JSONSerialization.jsonObject(with: self, options: []), let dataString = JSONSerialization.toJsonString(withJSONObject: json) {
            return dataString
        } else if let dataString = String(data: self, encoding: .utf8) {
            return dataString
        }
        return nil
    }
    
}

public extension Data {
    
    var toHexString: String {
        return toHexString()
    }
    
    var toHexLowercasedString: String {
        return toHexString(isLowercased: true)
    }
    
    private func toHexString(isLowercased: Bool = false) -> String {
        return map { String(format: "%02\(isLowercased ? "x" : "X")", $0) }.joined(separator: "")
    }

}

public extension String {
    
    /// 16进制字符串转为Data
    var hexToData: Data {
        let bytes = hexToBytes
        return Data(bytes: bytes)
    }
    
    // 16进制字符串转为 [UInt8]
    var hexToBytes: [UInt8] {
        assert(count % 2 == 0, "输入字符串格式不对，8位代表一个字符")
        var bytes = [UInt8]()
        var sum = 0
        // 整形 utf8 编码范围
        let intRange = 48...57
        // 小写 a~f 的 utf8 的编码范围
        let lowercaseRange = 97...102
        // 大写 A~F 的 utf8 的编码范围
        let uppercasedRange = 65...70
        for (index, c) in utf8CString.enumerated() {
            var intC = Int(c.byteSwapped)
            if intC == 0 {
                break
            } else if intRange.contains(intC) {
                intC -= 48
            } else if lowercaseRange.contains(intC) {
                intC -= 87
            } else if uppercasedRange.contains(intC) {
                intC -= 55
            } else {
                assertionFailure("输入字符串格式不对，每个字符都需要在0~9，a~f，A~F范围内")
            }
            sum = sum * 16 + intC
            // 每两个十六进制字母代表8位，即一个字节
            if index % 2 != 0 {
                bytes.append(UInt8(sum))
                sum = 0
            }
        }
        return bytes
    }
    
}

public extension Dictionary {
    
    var toString: String? {
        return JSONSerialization.toJsonString(withJSONObject: self, options: [])
    }
    
    var toPrettyPrintedString: String? {
        return JSONSerialization.toJsonString(withJSONObject: self)
    }
    
    var toData: Data? {
        return JSONSerialization.isValidJSONObject(self) ? try? JSONSerialization.data(withJSONObject: self) : nil
    }
    
}

public extension JSONSerialization {
    
    static func toJsonString(withJSONObject obj: Any, options: JSONSerialization.WritingOptions = .prettyPrinted) -> String? {
        var string: String? = nil
        if let data = try? JSONSerialization.data(withJSONObject: obj, options: options), let dataString = String(data: data, encoding: .utf8) {
            string = dataString
        }
        return string
    }
    
}

public extension UIColor {
    
    var toImage: UIImage? {
        return UIImage.setColor(self)
    }
    
}

public extension UIView {
    
    var toImage: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
    
}

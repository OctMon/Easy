//
//  EasyExtension.swift
//  Easy
//
//  Created by OctMon on 2018/9/28.
//

import UIKit

public protocol Then {}

public extension Then where Self: Any {
    
    /**
     ```
     let frame = CGRect().with {
         $0.origin.x = 10
         $0.size.width = 100
     }
     ```
     */
    func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try block(&copy)
        return copy
    }
    
    /**
     ```
     UserDefaults.standard.do {
         $0.set("octmon", forKey: "username")
         $0.set("octmon@qq.com", forKey: "email")
         $0.synchronize()
     }
     ```
     */
    func `do`(_ block: (Self) throws -> Void) rethrows {
        try block(self)
    }
    
}

public extension Then where Self: AnyObject {
    
    /**
     ```
     let label = UILabel().then {
         $0.textAlignment = .center
         $0.textColor = UIColor.black
         $0.text = "Hello, World!"
     }
     ```
     */
    func then(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
    
}

extension NSObject: Then {}

extension CGPoint: Then {}
extension CGRect: Then {}
extension CGSize: Then {}
extension CGVector: Then {}

extension UIEdgeInsets: Then {}
extension UIOffset: Then {}
extension UIRectEdge: Then {}

public extension Optional {
    
    /// 是否为nil
    var isNone: Bool {
        switch self {
        case .none:
            return true
        default:
            return false
        }
    }
    
    /// 是否不为nil
    var isSome: Bool {
        switch self {
        case .some(_):
            return true
        default:
            return false
        }
    }
    
    /// 值不为空返回当前值, 没有返回defualt
    ///
    /// - Parameter default: 默认值
    /// - Returns: 值
    func or(_ default: Wrapped) -> Wrapped {
        return self ?? `default`
    }
    
    /// 有值则传递至闭包进行处理, 否则返回nil
    func and<T>(then: (Wrapped) throws -> T?) rethrows -> T? {
        guard let unwrapped = self else { return nil }
        return try then(unwrapped)
    }
    
    /// 弱解析
    ///
    /// - Parameters:
    ///   - do: 有值则处理事件
    func unwrapped(_ do: (Wrapped) -> Void) {
        guard let unwapped = self else {
            return
        }
        `do`(unwapped)
    }
    
    /// 弱解析
    ///
    /// - Parameters:
    ///   - do: 有值则处理事件
    ///   - else: 值为 nil 则执行 else
    func unwrapped(_ do: (Wrapped) -> Void, else: (() -> Void)? = nil) -> Void {
        guard let unwapped = self else {
            `else`?()
            return
        }
        `do`(unwapped)
    }
    
}

public extension Optional where Wrapped == String {
    
    /// 为空返回 ""
    var orEmpty: String {
        return self ?? ""
    }
    
}

public extension Bool {
    
    /// 或
    func or(_ other: @autoclosure () -> Bool) -> Bool {
        return self || other()
    }
    /// 或
    func or(_ other: (() -> Bool)) -> Bool {
        return self || other()
    }
    /// 且
    func and(_ other: @autoclosure () -> Bool) -> Bool {
        return self && other()
    }
    /// 且
    func and(_ other: (() -> Bool)) -> Bool {
        return self && other()
    }
    
}

public extension Double {
    
    var digits: [Int] {
        var digits: [Int] = []
        for char in String(self) {
            if let int = Int(String(char)) {
                digits.append(int)
            }
        }
        return digits
    }
    
    var abs: Double {
        return Swift.abs(self)
    }
    
    /// 本身的四舍五入
    /**
     let num = 5.67
     EasyLog.debug(num.round) // -> 6.0
     */
    var round: Double {
        return Foundation.round(self)
    }
    
    /// 大于本身的最小整数
    /**
     let num = 5.67
     EasyLog.debug(num.ceil) // -> 6.0
     */
    var ceil: Double {
        return Foundation.ceil(self)
    }
    
    /// 小于本身最大整数
    /**
     let num = 5.67
     EasyLog.debug(num.floor) // -> 5.0
     */
    var floor: Double {
        return Foundation.floor(self)
    }
    
    var displayPriceDivide100: String {
        return (self / 100).displayPrice
    }
    
    var displayPrice: String {
        return String(format: "%.2f", self)
    }
    
}

public extension String {

    var dispayPriceAutoZero: String {
        var price = self
        if price.hasSuffix(".00") {
            price.subString(to: price.count - 3)
        }
        return price
    }

}

public extension CGFloat {
    
    /// 本身的四舍五入
    /**
     let num = 5.67
     EasyLog.debug(num.round) // -> 6.0
     */
    var round: CGFloat {
        return Foundation.round(self)
    }
    
    /// 大于本身的最小整数
    /**
     let num = 5.67
     EasyLog.debug(num.ceil) // -> 6.0
     */
    var ceil: CGFloat {
        return Foundation.ceil(self)
    }
    
    /// 小于本身最大整数
    /**
     let num = 5.67
     EasyLog.debug(num.floor) // -> 5.0
     */
    var floor: CGFloat {
        return Foundation.floor(self)
    }
    
    /// CGSize
    /**
     CGSize(width: .screenWidth, height: 0)
     */
    static var screenWidth: CGFloat {
        return EasyApp.screenWidth
    }
    
    /// CGSize
    /**
     CGSize(width: 0, height: .screenHeight)
     */
    static var screenHeight: CGFloat {
        return EasyApp.screenHeight
    }
    
}

public extension Int {
    
    var abs: Int {
        return Swift.abs(self)
    }
    
}

public extension CGSize {
    
    var isEmpty: Bool {
        return isWidthEmpty || isHeightEmpty
    }
    
    var isWidthEmpty: Bool {
        return self.width <= 0
    }
    
    var isHeightEmpty: Bool {
        return self.height <= 0
    }
    
}

public extension String {
    
    mutating func trimmedWithoutSpacesAndNewLines() {
        self = trimmingWithoutSpacesAndNewLines
    }
    
    var trimmingWithoutSpacesAndNewLines: String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    mutating func trimmedAllWithoutSpacesAndNewLines() {
        self = trimmingAllWithoutSpacesAndNewLines
    }
    
    var trimmingAllWithoutSpacesAndNewLines: String {
        return replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
    }
    
    func replace(_ string: String, to: String) -> String {
        return self.replacingOccurrences(of: string, with: to)
    }
    
    func remove(_ string: String) -> String {
        return replace(string, to: "")
    }
    
    func remove(_ strings: [String]) -> String {
        var temp = self
        strings.forEach({ temp = temp.replace($0, to: "") })
        return temp
    }
    
    /// 数组中是否包含该self
    /**
     let result1 = "octmon".is(in: ["oct_mon1234567", "89"])
     EasyLog.debug(result1) // -> false
     let result2 = "octmon1234567".is(in: ["octmon1234567", "def"])
     EasyLog.debug(result2) // -> true
     */
    func `is`(in equleTo: [String]) -> Bool {
        return equleTo.contains(where: { self == $0 })
    }
    
    /// 数组中是否包含该前缀
    /**
     let result1 = "octmon".hasPrefixs(in: ["_octmon1234567", "89"])
     EasyLog.debug(result1) // -> false
     let result2 = "octmon1234567".hasPrefixs(in: ["octmon1234567", "def"])
     EasyLog.debug(result2) // -> true
     */
    func hasPrefixs(in prefixs: [String]) -> Bool {
        return prefixs.contains(where: { self.hasPrefix($0) })
    }
    
    /// 数组中是否包含该后缀
    /**
     let result1 = "octmon".hasSuffixs(in: ["_octmon1234567", "mon8"])
     EasyLog.debug(result1) // -> false
     let result2 = "octmon1234567".hasSuffixs(in: ["octmon1234567", "89"])
     EasyLog.debug(result2) // -> true
     */
    func hasSuffixs(in suffixs: [String]) -> Bool {
        return suffixs.contains(where: { self.hasSuffix($0) })
    }
    
    /**
     let result1 = "octmon1234567".contains(in: ["abc", "d"])
     EasyLog.debug(result1) // -> false
     let result2 = "octmon1234567".contains(in: ["abc", "1"])
     EasyLog.debug(result2) // -> true
     */
    func contains(in contains: [String]) -> Bool {
        return contains.contains(where: { self.contains($0) })
    }
    
    mutating func reverse() {
        self = reversing
    }
    
    var reversing: String {
        return String(reversed())
    }
    
    func components(_ separator: String) -> [String] {
        return components(separatedBy: separator).filter {
            return !$0.trimmingWithoutSpacesAndNewLines.isEmpty
        }
    }
    
    func contain(_ subStirng: String, caseSensitive: Bool = true) -> Bool {
        if !caseSensitive {
            return range(of: subStirng, options: .caseInsensitive) != nil
        }
        return range(of: subStirng) != nil
    }
    
    func count(of subString: String, caseSensitive: Bool = true) -> Int {
        if !caseSensitive {
            return lowercased().components(separatedBy: subString).count - 1
        }
        return components(separatedBy: subString).count - 1
    }
    
    func hasPrefix(_ prefix: String, caseSensitive: Bool = true) -> Bool {
        if !caseSensitive {
            return lowercased().hasPrefix(prefix.lowercased())
        }
        return hasPrefix(prefix)
    }
    
    func hasSuffix(_ suffix: String, caseSensitive: Bool = true) -> Bool {
        if !caseSensitive {
            return lowercased().hasSuffix(suffix.lowercased())
        }
        return hasSuffix(suffix)
    }
    
    func joined(separator: String) -> String {
        return map({ "\($0)" }).joined(separator: separator)
    }
    
    mutating func joining(_ separator: String) {
        self = joined(separator: separator)
    }
    
    /// 字符串截取
    ///
    /// - Parameters:
    ///   - from: 从下标from开始截取
    ///   - to: 截取多少位
    mutating func subString(from: Int = 0, to: Int) {
        let fromIndex = index(startIndex, offsetBy: from)
        let toIndex = index(fromIndex, offsetBy: to)
        self = String(self[fromIndex..<toIndex])
    }
    
    
    func copyToPasteboard() {
        UIPasteboard.general.string = self
    }
    
    
    var urlEncode: String? {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    var urlEncodeValue: String {
        return urlEncode ?? self
    }
    
    var urlDecode: String? {
        return removingPercentEncoding
    }
    
    var urlDecodeValue: String {
        return urlDecode ?? self
    }
    
    var attributedString: NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }
    
    func getWidth(with height: CGFloat, font: UIFont, lineBreakMode: NSLineBreakMode = .byTruncatingTail) -> CGFloat {
        return ceil(getSize(with: CGSize(width: CGFloat(Double.greatestFiniteMagnitude), height: height), font: font, lineBreakMode: lineBreakMode).width)
    }
    
    func getHeight(with width: CGFloat, font: UIFont, lineBreakMode: NSLineBreakMode = .byTruncatingTail) -> CGFloat {
        return ceil(getSize(with: CGSize(width: width, height: CGFloat(Double.greatestFiniteMagnitude)), font: font, lineBreakMode: lineBreakMode).height)
    }
    
    func getSize(with size: CGSize, font: UIFont, lineBreakMode: NSLineBreakMode = .byTruncatingTail) -> CGSize {
        var attributed: [NSAttributedString.Key: Any] = [.font: font]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = lineBreakMode
        attributed.updateValue(paragraphStyle, forKey: .paragraphStyle)
        return (self as NSString).boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributed, context: nil).size
    }
    
}

public extension URLRequest {
    
    private var easyRequestSeparator: String { return "\n->->->->->->->->->->Request->->->->->->->->->\n" }
    private func easyStatusCodeSeparator(statusCode: Int = NSURLErrorNotConnectedToInternet) -> String { return "\n----------------------\(statusCode)------------------->" }
    private var easyResponseSeparator: String { return "\n->->->->->->->->->->Response->->->->->->->->->\n" }
    
    @discardableResult
    func printRequestLog(isPrintBase64DecodeBody: Bool = false) -> String {
        return printRequestLog(isPrintBase64DecodeBody: isPrintBase64DecodeBody, separator: [easyRequestSeparator, easyRequestSeparator])
    }
    
    @discardableResult
    private func printRequestLog(isPrintBase64DecodeBody: Bool = false, separator: [String]) -> String {
        var separator = Array(separator.reversed())
        let _url = url?.absoluteString ?? ""
        let _httpMethod = httpMethod ?? ""
        let _timeout = timeoutInterval
        let _httpBody = httpBody?.toJsonString
        var log = "\(separator.popLast() ?? "")[URL]\t\t\(_url)\n[Method]\t\t\(_httpMethod)\n[Timeout]\t\(_timeout)"
        if let allHTTPHeaderFields = allHTTPHeaderFields, allHTTPHeaderFields.count > 0, let header = JSONSerialization.toJsonString(withJSONObject: allHTTPHeaderFields) {
            log += "\n[Header]\n\(header)"
        }
        if let body = _httpBody {
            log += "\n[Body]\n\(body)"
            if let json = Data(base64Encoded: body, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)?.toJsonString, isPrintBase64DecodeBody {
                log += "\n[Body -> Base64Decode]\n\(json)"
            }
        }
        log += "\(separator.popLast() ?? "")"
        EasyLog.print(log)
        return log
    }
    
    @discardableResult
    func printResponseLog(_ isPrintHeader: Bool = false, isPrintBase64DecodeBody: Bool = false, response: HTTPURLResponse?, data: Data?, error: Error?, requestDuration: TimeInterval?) -> (requestLog: String, responseLog: String) {
        var requestLog = ""
        var responseLog = ""
        if let response = response {
            requestLog = printRequestLog(isPrintBase64DecodeBody: isPrintBase64DecodeBody, separator: [easyResponseSeparator, easyStatusCodeSeparator(statusCode: response.statusCode)])
            if let requestDuration = requestDuration {
                responseLog += "[Duration]\t\(requestDuration)"
            }
            if isPrintHeader, let header = JSONSerialization.toJsonString(withJSONObject: response.allHeaderFields) {
                responseLog += "\n[Header]\n\(header)"
            }
        } else {
            requestLog = printRequestLog(isPrintBase64DecodeBody: isPrintBase64DecodeBody, separator: [easyResponseSeparator, easyStatusCodeSeparator()])
            if let requestDuration = requestDuration {
                responseLog += "[Duration]\t\(requestDuration)"
            }
        }
        if let error = error {
            responseLog += "\n[Error]\t\t\(error.localizedDescription)"
        }
        if let data = data {
            responseLog += "\n[Size]\t\t\(data)"
            if let data = data.toJsonString {
                responseLog += "\n[Data]\n\(data)"
                if let json = Data(base64Encoded: data, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)?.toJsonString, isPrintBase64DecodeBody {
                    responseLog += "\n[Data -> Base64Decode]\n\(json)"
                }
            }
        }
        responseLog += easyResponseSeparator
        EasyLog.print(responseLog)
        return (requestLog, responseLog)
    }
    
}

public extension URLRequest {
    
    mutating func setHTTPHeaderFields(_ fields: [String: String?]) {
        fields.forEach({ setValue($0.value, forHTTPHeaderField: $0.key) })
    }
    
}

public extension JSONDecoder {
    
    func decode<T>(_ type: T.Type, from data: Data?) -> T? where T : Decodable {
        if let data = data {
            return try? decode(type, from: data)
        }
        return nil
    }
    
}

public extension Dictionary {
    
    private static func value(for json: EasyParameters, in path: [String]) -> Any? {
        if path.count == 1 {
            return json[path[0]] as Any
        }
        var path = path
        return value(for: json, in: &path)
    }
    
    private static func value(for json: EasyParameters, in path: inout [String]) -> Any? {
        if let first = path.first, let json = json[first] as? EasyParameters {
            path.removeFirst()
            return value(for: json, in: &path)
        }
        if let last = path.last {
            return json[last] as Any
        }
        return nil
    }
    
    subscript(path: [String]) -> Any? {
        if let json = self as? EasyParameters {
            return Dictionary.value(for: json, in: path)
        }
        return nil
    }
    
}

public extension UIImage {
    
    convenience init?(for aClass: AnyClass, forResource bundleName: String, forImage imageName: String) {
        var resource = bundleName
        if !bundleName.hasSuffix(".bundle") {
            resource = bundleName + ".bundle"
        }
        if let url = Bundle(for: aClass).url(forResource: resource, withExtension: nil) {
            var file = ""
            if let tmp = Bundle(url: url)?.path(forResource: imageName, ofType: nil) {
                file = tmp
            } else if let tmp = Bundle(url: url)?.path(forResource: imageName + ".png", ofType: nil) {
                file = tmp
            } else if let tmp = Bundle(url: url)?.path(forResource: imageName + "@2x.png", ofType: nil) {
                file = tmp
            }
            self.init(contentsOfFile: file)
        } else {
            self.init()
        }
    }
    
}

public extension UIColor {
    
    static var hex333333: UIColor { return UIColor.hex(0x333333) }
    static var hex666666: UIColor { return UIColor.hex(0x666666) }
    static var hex999999: UIColor { return UIColor.hex(0x999999) }
    static var hexCCCCCC: UIColor { return UIColor.hex(0xCCCCCC) }
    static var textFieldPlaceholder: UIColor {
        struct Once {
            private init() {
                if let placeholderColor = (UITextField().then {
                    $0.placeholder = " "
                    }.value(forKeyPath: "_placeholderLabel.textColor")) as? UIColor {
                    color = placeholderColor
                }
            }
            static var shared = Once()
            var color: UIColor!
        }
        return Once.shared.color
    }
    
}

public extension UIColor {
    
    var red: Int {
        var red: CGFloat = 0
        getRed(&red, green: nil, blue: nil, alpha: nil)
        return Int(red * 255)
    }
    
    var green: Int {
        var green: CGFloat = 0
        getRed(nil, green: &green, blue: nil, alpha: nil)
        return Int(green * 255)
    }
    
    var blue: Int {
        var blue: CGFloat = 0
        getRed(nil, green: nil, blue: &blue, alpha: nil)
        return Int(blue * 255)
    }
    
    var alpha: CGFloat {
        var alpha: CGFloat = 0
        getRed(nil, green: nil, blue: nil, alpha: &alpha)
        return alpha
    }
    
    var isLight: Bool {
        var white: CGFloat = 0.0
        getWhite(&white, alpha: nil)
        return white >= 0.5
    }
    
    static var random: UIColor {
        return UIColor.rgb(red: Int(arc4random_uniform(255)), green: Int(arc4random_uniform(255)), blue: Int(arc4random_uniform(255)))
    }
    
    static func rgb(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha))
    }
    
    static func hex(_ hex: Int, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: CGFloat(((hex & 0xFF0000) >> 16)) / 255.0, green: CGFloat(((hex & 0xFF00) >> 8)) / 255.0, blue: CGFloat((hex & 0xFF)) / 255.0, alpha: alpha)
    }
    
    static func hex(_ hex: String) -> UIColor {
        let colorString: String = hex.replacingOccurrences(of: "#", with: "").uppercased()
        var alpha: CGFloat = 0.0, red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0
        switch colorString.count {
        case 3: // #RGB
            alpha = 1.0
            red = UIColor.colorComponentFrom(colorString, start: 0, lenght: 1)
            green = UIColor.colorComponentFrom(colorString, start: 1, lenght: 1)
            blue = UIColor.colorComponentFrom(colorString, start: 2, lenght: 1)
        case 4: // #ARGB
            alpha = UIColor.colorComponentFrom(colorString, start: 0, lenght: 1)
            red = UIColor.colorComponentFrom(colorString, start: 1, lenght: 1)
            green = UIColor.colorComponentFrom(colorString, start: 2, lenght: 1)
            blue = UIColor.colorComponentFrom(colorString, start: 3, lenght: 1)
        case 6: // #RRGGBB
            alpha = 1.0
            red = UIColor.colorComponentFrom(colorString, start: 0, lenght: 2)
            green = UIColor.colorComponentFrom(colorString, start: 2, lenght: 2)
            blue = UIColor.colorComponentFrom(colorString, start: 4, lenght: 2)
        case 8: // #AARRGGBB
            alpha = UIColor.colorComponentFrom(colorString, start: 0, lenght: 2)
            red = UIColor.colorComponentFrom(colorString, start: 2, lenght: 2)
            green = UIColor.colorComponentFrom(colorString, start: 4, lenght: 2)
            blue = UIColor.colorComponentFrom(colorString, start: 6, lenght: 2)
        default:
            break
        }
        return UIColor(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    private static func colorComponentFrom(_ string: String, start: Int, lenght: Int) -> CGFloat {
        var substring: NSString = string as NSString
        substring = substring.substring(with: NSMakeRange(start, lenght)) as NSString
        let fullHex = lenght == 2 ? substring as String : "\(substring)\(substring)"
        var hexComponent: CUnsignedInt = 0
        Scanner(string: fullHex).scanHexInt32(&hexComponent)
        return CGFloat(hexComponent) / 255.0
    }
}

public extension UIImage {
    
    static func setColor(_ color: UIColor, frame: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)) -> UIImage? {
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(frame)
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else { return nil }
        UIGraphicsEndImageContext()
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: UIImage.Orientation.up)
    }
    
    func tint(_ color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height) as CGRect
        guard let cgImage = cgImage else { return nil }
        context?.clip(to: rect, mask: cgImage)
        color.setFill()
        context?.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// 平铺
    ///
    /// - Parameter size: 渲染尺寸
    /// - Returns: 图片平铺生成指定大小图片
    func tile(size: CGSize) -> UIImage? {
        return UIImage.setColor(UIColor(patternImage: self), frame: CGRect(origin: CGPoint.zero, size: size))
    }
    
    /// 将图片缩放成指定尺寸（多余部分自动删除）
    /**
     let image = UIColor.red.toImage
     let newImage = image?.crop(to: CGSize(width: 400, height: 300))
     */
    func crop(to newSize: CGSize) -> UIImage? {
        let aspectWidth  = newSize.width / size.width
        let aspectHeight = newSize.height / size.height
        let aspectRatio = max(aspectWidth, aspectHeight)
        
        var scaledImageRect = CGRect.zero
        scaledImageRect.size.width = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        scaledImageRect.origin.x = (newSize.width - size.width * aspectRatio) / 2.0
        scaledImageRect.origin.y = (newSize.height - size.height * aspectRatio) / 2.0
        
        UIGraphicsBeginImageContext(newSize)
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    /// 将图片裁剪成指定比例（多余部分自动删除）
    /**
     // 将图片转成 4:3 比例
     let newImage = image?.crop(ratio: 4/3)
     */
    func crop(ratio: CGFloat) -> UIImage? {
        var newSize: CGSize
        if size.width / size.height > ratio {
            newSize = CGSize(width: size.height * ratio, height: size.height)
        } else {
            newSize = CGSize(width: size.width, height: size.width / ratio)
        }
        
        var rect = CGRect.zero
        rect.size.width = size.width
        rect.size.height = size.height
        rect.origin.x = (newSize.width - size.width ) / 2.0
        rect.origin.y = (newSize.height - size.height ) / 2.0
        
        UIGraphicsBeginImageContext(newSize)
        draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func resize(to size: CGSize) -> UIImage {
        let resizedImage: UIImage
        UIGraphicsBeginImageContext(CGSize(width: size.width, height: size.height))
        UIGraphicsGetCurrentContext()?.interpolationQuality = .none
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    static var launchImage: UIImage? {
        if let launchImage = launchImageInStoryboard {
            return launchImage
        }
        return launchImageInAssets
    }
    
    static var launchImageInAssets: UIImage? {
        guard let info = Bundle.main.infoDictionary else { return nil }
        if let imagesDict = info["UILaunchImages"] as? [[String: String]] {
            for dict in imagesDict {
                if EasyApp.screenSize.equalTo(NSCoder.cgSize(for: dict["UILaunchImageSize"]!)) {
                    return UIImage(named: dict["UILaunchImageName"]!)
                }
            }
            let launchImageName = (info["UILaunchImageFile"] as? String) ?? ""
            if UIDevice.current.userInterfaceIdiom == .pad {
                if UIApplication.shared.statusBarOrientation.isPortrait {
                    return UIImage(named: launchImageName + "-Portrait")
                }
                if UIDevice.current.orientation.isLandscape {
                    return UIImage(named: launchImageName + "-Landscape")
                }
            }
            return UIImage(named: launchImageName)
        }
        return nil
    }

    static var launchImageInStoryboard: UIImage? {
        guard let launchStoryboardName = Bundle.main.infoDictionary?["UILaunchStoryboardName"] as? String else { return nil }
        guard let vc = UIStoryboard(name: launchStoryboardName, bundle: nil).instantiateInitialViewController() else { return nil }
        let view = vc.view
        view?.frame = EasyApp.screenBounds
        return view?.toImage
    }
    
}

public extension UIFont {
    
    static var size6: UIFont { return UIFont.systemFont(ofSize: 6) }
    static var size7: UIFont { return UIFont.systemFont(ofSize: 7) }
    static var size8: UIFont { return UIFont.systemFont(ofSize: 8) }
    static var size9: UIFont { return UIFont.systemFont(ofSize: 9) }
    static var size10: UIFont { return UIFont.systemFont(ofSize: 10) }
    static var size11: UIFont { return UIFont.systemFont(ofSize: 11) }
    static var size12: UIFont { return UIFont.systemFont(ofSize: 12) }
    static var size13: UIFont { return UIFont.systemFont(ofSize: 13) }
    static var size14: UIFont { return UIFont.systemFont(ofSize: 14) }
    static var size15: UIFont { return UIFont.systemFont(ofSize: 15) }
    static var size16: UIFont { return UIFont.systemFont(ofSize: 16) }
    static var size17: UIFont { return UIFont.systemFont(ofSize: 17) }
    static var size18: UIFont { return UIFont.systemFont(ofSize: 18) }
    static var size19: UIFont { return UIFont.systemFont(ofSize: 19) }
    static var size20: UIFont { return UIFont.systemFont(ofSize: 20) }
    static var size21: UIFont { return UIFont.systemFont(ofSize: 21) }
    static var size22: UIFont { return UIFont.systemFont(ofSize: 22) }
    static var size23: UIFont { return UIFont.systemFont(ofSize: 23) }
    static var size24: UIFont { return UIFont.systemFont(ofSize: 24) }
    static var size28: UIFont { return UIFont.systemFont(ofSize: 28) }
    static var size32: UIFont { return UIFont.systemFont(ofSize: 32) }
    static var size36: UIFont { return UIFont.systemFont(ofSize: 36) }
    static var size48: UIFont { return UIFont.systemFont(ofSize: 48) }
    static var size64: UIFont { return UIFont.systemFont(ofSize: 64) }
    
    var semibold: UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: pointSize, weight: .semibold)
        } else {
            return self
        }
    }
    
    var medium: UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: pointSize, weight: .medium)
        } else {
            return self
        }
    }
    
    var regular: UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: pointSize, weight: .regular)
        } else {
            return self
        }
    }
    
}

public extension UIButton {
    
    func setBackgroundImage(_ backgroundImage: UIImage?, cornerRadius: CGFloat, `for` state: UIControl.State = .normal) {
        setBackgroundImage(backgroundImage, for: state)
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
    }
    
}

public extension UITextField {
    
    /// 左内边距
    func setLeft(padding: CGFloat) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: 1))
        view.backgroundColor = .clear
        leftView = view
        leftViewMode = .always
    }
    
    /// 右内边距
    func setRight(padding: CGFloat) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: 1))
        view.backgroundColor = .clear
        rightView = view
        rightViewMode = .always
    }
    
    /// 左边icon
    func setLeftIcon(image: UIImage, size: CGSize? = nil, padding: CGFloat) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .left
        self.leftView = imageView
        var imageSize: CGSize!
        if size == nil {
            imageSize = image.size
        } else {
            imageSize = size
        }
        self.leftView?.frame.size = CGSize(width: imageSize.width + padding, height: imageSize.height)
        self.leftViewMode = .always
    }
    
    func setLimit(_ length: Int, handler: (() -> Void)? = nil) {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nil, queue: OperationQueue.main) { [weak self] (_) in
            guard let `self` = self else { return }
            if (((self.text! as NSString).length > length) && self.markedTextRange == nil) {
                self.text = (self.text! as NSString).substring(to: length)
                handler?()
            }
        }
    }
    
    func setDoneButton(barStyle: UIBarStyle = .default, title: String? = "完成") {
        let toolbar = UIToolbar()
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: title, style: .done, target: self, action: #selector(UITextField.doneAction))]
        toolbar.barStyle = barStyle
        toolbar.sizeToFit()
        inputAccessoryView = toolbar
    }
    
    @objc private func doneAction() { endEditing(true) }
    
}

public extension UITextView {
    
    func setLimit(_ length: Int, handler: (() -> Void)? = nil) {
        NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let `self` = self else { return }
            if (((self.text! as NSString).length > length) && self.markedTextRange == nil) {
                self.text = (self.text! as NSString).substring(to: length)
                handler?()
            }
        }
    }
    
}

public extension UITableView {
    
    func setHeaderZero() {
        tableHeaderView = UIView()
    }
    
    func setFooterZero() {
        tableFooterView = UIView()
    }
    
    func setHeaderHeight(_ height: CGFloat) {
        let view = UIView()
        view.frame.size.height = height
        tableHeaderView = view
    }
    
    func setFooterHeight(_ height: CGFloat) {
        let view = UIView()
        view.frame.size.height = height
        tableFooterView = view
    }
    
    func registerReusableCell<T: UITableViewCell>(_ cell: T.Type) {
        let name = cell.toString
        let xib = Bundle.main.path(forResource: name, ofType: "nib")
        if let path = xib {
            let exists = FileManager.default.fileExists(atPath: path)
            if exists {
                register(UINib(nibName: name, bundle: Bundle.main), forCellReuseIdentifier: cell.toString)
            }
        } else {
            register(cell.self, forCellReuseIdentifier: cell.toString)
        }
    }
    
    func dequeueReusableCell<T: UITableViewCell>(with cell: T.Type = T.self) -> T {
        guard let reuseableCell = dequeueReusableCell(withIdentifier: cell.toString ) as? T else {
            fatalError("Failed to dequeue a cell with identifier \(cell.toString)")
        }
        return reuseableCell
    }
    
    func registerReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ headerFooterView: T.Type = T.self) {
        let name = headerFooterView.toString
        let xib = Bundle.main.path(forResource: name, ofType: "nib")
        if let path = xib {
            let exists = FileManager.default.fileExists(atPath: path)
            if exists {
                register(UINib(nibName: name, bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: headerFooterView.toString)
            }
        } else {
            register(headerFooterView.self, forHeaderFooterViewReuseIdentifier: headerFooterView.toString)
        }
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(with type: T.Type = T.self) -> T {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: type.toString) as? T else {
            fatalError("Failed to dequeue a header footer view with identifier \(type.toString)")
        }
        return view
    }
    
}

public extension UICollectionView {
    
    func registerReusableCell<T: UICollectionViewCell>(_ cell: T.Type) {
        let name = cell.toString
        let xibPath = Bundle.main.path(forResource: name, ofType: "nib")
        if let path = xibPath {
            let exists = FileManager.default.fileExists(atPath: path)
            if exists {
                register(UINib(nibName: name, bundle: Bundle.main), forCellWithReuseIdentifier: cell.toString)
                return
            }
        }
        register(cell.self, forCellWithReuseIdentifier: cell.toString)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath, with cell: T.Type = T.self) -> T {
        guard let reuseableCell = dequeueReusableCell(withReuseIdentifier: cell.toString, for: indexPath) as? T else {
            fatalError("Failed to dequeue a cell with identifier \(cell.toString)")
        }
        return reuseableCell
    }
    
    func registerReusableView<T: UICollectionReusableView>(supplementaryViewType: T.Type = T.self, ofKind elementKind: String) {
        self.register(supplementaryViewType.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: supplementaryViewType.toString)
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind elementKind: String, for indexPath: IndexPath, viewType: T.Type = T.self) -> T {
        let view = self.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: viewType.toString, for: indexPath)
        guard let typedView = view as? T else {
            fatalError(
                "Failed to dequeue a supplementary view with identifier \(viewType.toString) "
                    + "matching type \(viewType.self) "
            )
        }
        return typedView
    }
    
}

public extension UIView {
    
    var x: CGFloat {
        get { return self.frame.origin.x }
        set { self.frame.origin.x = newValue }
    }
    var y: CGFloat {
        get { return self.frame.origin.y }
        set { self.frame.origin.y = newValue }
    }
    
    var width: CGFloat {
        get { return self.frame.width }
        set { self.frame.size.width = newValue }
    }
    var height: CGFloat {
        get { return self.frame.height }
        set { self.frame.size.height = newValue }
    }
    
    var size: CGSize {
        get { return self.frame.size }
        set { self.frame.size = newValue }
    }
    
    var origin: CGPoint {
        get { return self.frame.origin }
        set { self.frame.origin = newValue }
    }
    
    var left: CGFloat {
        get { return self.frame.origin.x }
        set { self.frame.origin.x = newValue }
    }
    var right: CGFloat {
        get { return self.frame.origin.x + self.frame.size.width }
        set { self.frame.origin.x = newValue - self.frame.size.width }
    }
    
    var top: CGFloat {
        get { return self.frame.origin.y }
        set { self.frame.origin.y = newValue }
    }
    var bottom: CGFloat {
        get { return self.frame.origin.y + self.frame.size.height }
        set { self.frame.origin.y = newValue - self.frame.size.height }
    }
    
    var centerX: CGFloat {
        get { return self.center.x }
        set { self.center.x = newValue }
    }
    
    var centerY: CGFloat {
        get { return self.center.y }
        set { self.center.y = newValue }
    }
    
    func setCornerRadius(_ cornerRadius: CGFloat? = nil) {
        clipsToBounds = true
        if let cornerRadius = cornerRadius {
            layer.cornerRadius = cornerRadius
        } else {
            layer.cornerRadius = min(frame.size.height, frame.size.width) * 0.5
        }
    }
    
}

public extension UIView {
    
    /// 摇一摇动画
    func animationShake() {
        let shake: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform")
        shake.values = [NSValue(caTransform3D: CATransform3DMakeTranslation(-5.0, 0.0, 0.0)), NSValue(caTransform3D: CATransform3DMakeTranslation(5.0, 0.0, 0.0))]
        shake.autoreverses = true
        shake.repeatCount = 2.0
        shake.duration = 0.07
        layer.add(shake, forKey:"shake")
    }
    
    /// 脉冲动画
    func animationPulse(_ duration: CFTimeInterval = 0.25) {
        UIView.animate(withDuration: TimeInterval(duration / 6), animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { (finished) -> Void in
            if finished {
                UIView.animate(withDuration: TimeInterval(duration / 6), animations: { () -> Void in
                    self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
                }, completion: { (finished: Bool) -> Void in
                    if finished {
                        UIView.animate(withDuration: TimeInterval(duration / 6), animations: { () -> Void in
                            self.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
                        }, completion: { (finished: Bool) -> Void in
                            if finished {
                                UIView.animate(withDuration: TimeInterval(duration / 6), animations: { () -> Void in
                                    self.transform = CGAffineTransform(scaleX: 0.985, y: 0.985)
                                }, completion: { (finished: Bool) -> Void in
                                    if finished {
                                        UIView.animate(withDuration: TimeInterval(duration / 6), animations: { () -> Void in
                                            self.transform = CGAffineTransform(scaleX: 1.007, y: 1.007)
                                        }, completion: { (finished: Bool) -> Void in
                                            if finished {
                                                UIView.animate(withDuration: TimeInterval(duration / 6), animations: { () -> Void in
                                                    self.transform = CGAffineTransform(scaleX: 1, y: 1)
                                                })
                                            }
                                        })
                                    }
                                })
                            }
                        })
                    }
                })
            }
        })
    }
    
    /// 心跳动画
    func animationHeartbeat(_ duration: CFTimeInterval = 0.25) {
        let maxSize: CGFloat = 1.4, durationPerBeat: CFTimeInterval = 0.5
        let animation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform")
        let scale1: CATransform3D = CATransform3DMakeScale(0.8, 0.8, 1)
        let scale2: CATransform3D = CATransform3DMakeScale(maxSize, maxSize, 1)
        let scale3: CATransform3D = CATransform3DMakeScale(maxSize - 0.3, maxSize - 0.3, 1)
        let scale4: CATransform3D = CATransform3DMakeScale(1.0, 1.0, 1)
        let frameValues: Array = [NSValue(caTransform3D: scale1), NSValue(caTransform3D: scale2), NSValue(caTransform3D: scale3), NSValue(caTransform3D: scale4)]
        animation.values = frameValues
        let frameTimes: Array = [NSNumber(value: 0.05 as Float), NSNumber(value: 0.2 as Float), NSNumber(value: 0.6 as Float), NSNumber(value: 1.0 as Float)]
        animation.keyTimes = frameTimes
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.duration = TimeInterval(durationPerBeat)
        animation.repeatCount = Float(duration / durationPerBeat)
        layer.add(animation, forKey: "heartbeat")
    }
    
}

public extension UIView {
    
    private var separatorTag: Int { return 990909 }
    
    private func addSeparator(isTopSeparator: Bool, color: UIColor = UIColor.globalSeparator, lineHeight: CGFloat = 0.5, left: CGFloat = 0, right: CGFloat = 0) {
        removeSeparator()
        
        let separatorView = UIView()
        separatorView.backgroundColor = color
        separatorView.tag = separatorTag
        addSubview(separatorView)
        separatorView.snp.makeConstraints({ (make) in
            make.height.equalTo(lineHeight)
            make.left.equalTo(self).offset(left)
            if isTopSeparator {
                make.top.equalTo(self)
            } else {
                make.bottom.equalTo(self)
            }
            make.right.equalTo(self).offset(-right)
        })
    }
    
    func addSeparatorTop(color: UIColor = UIColor.globalSeparator, lineHeight: CGFloat = 0.5, left: CGFloat = 0, right: CGFloat = 0) {
        addSeparator(isTopSeparator: true, color: color, lineHeight: lineHeight, left: left, right: right)
    }
    
    func addSeparatorBottom(color: UIColor = UIColor.globalSeparator, lineHeight: CGFloat = 0.5, left: CGFloat = 0, right: CGFloat = 0) {
        addSeparator(isTopSeparator: false, color: color, lineHeight: lineHeight, left: left, right: right)
    }
    
    func removeSeparator() {
        subviews.forEach({ guard $0.tag == separatorTag else { return }; $0.removeFromSuperview() })
    }
    
    func removeAllSubviews() {
        subviews.forEach({ $0.removeFromSuperview() })
    }
    
    func removeAllSubviews(with type: AnyClass) {
        subviews.forEach({ if $0.isKind(of: type) { $0.removeFromSuperview() } })
    }

}

#if canImport(SnapKit)
import SnapKit

public extension UIView {
    
    /// 页面底部添加按钮
    /**
     let titles = ["确定".attributedString, "取消".attributedString]
         view.addBottomButton(titles: titles, height: 60, backgroundImages: titles.enumerated().map {
     $0.offset == 0 ? UIColor.red.toImage : UIColor.yellow.toImage
     }) { (offset) in
         Log.debug(offset)
     }
     */
    func addBottomButton(titles: [NSAttributedString?], height: CGFloat, backgroundImages: [UIImage?], tap: @escaping (Int) -> Void) {
        var bottomButtons = [UIButton]()
        
        let count = titles.count
        for offset in 0..<count {
            let button = UIButton()
            addSubview(button)
            
            button.snp.makeConstraints({ (make) in
                if offset == 0 {
                    make.left.equalToSuperview()
                    make.height.equalTo(height)
                    make.bottom.equalToSuperview().offset(-EasyApp.safeBottomEdge)
                } else if offset > 0 {
                    make.left.equalTo(bottomButtons[offset - 1].snp.right)
                    make.size.equalTo(bottomButtons[offset - 1])
                    make.bottom.equalTo(bottomButtons[offset - 1])
                    if offset == count - 1 {
                        make.right.equalToSuperview()
                    }
                }
                
                if count == 1 {
                    make.right.equalToSuperview()
                }
            })
            
            button.setAttributedTitle(titles[offset], for: .normal)
            button.setBackgroundImage(backgroundImages[offset], cornerRadius: 0)
            button.tap { (_) in
                tap(offset)
            }
            bottomButtons.append(button)
        }
    }
    
}
#endif

public extension UIViewController {
    
    func makeRootViewController(_ backgroundColor: UIColor = UIColor.globalBackground) -> UIWindow {
        let main = UIWindow(frame: UIScreen.main.bounds)
        main.backgroundColor = backgroundColor
        main.rootViewController = self
        main.makeKeyAndVisible()
        return main
    }
    
}

public extension UIViewController {
    
    func hideKeyboardWhenTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

public extension UIViewController {
    
    var navgationBottom: CGFloat { return EasyApp.statusBarHeight + (self.navigationController?.navigationBar.frame.height ?? 0) }
    
    var navgationBar: UINavigationBar? { return navigationController?.navigationBar }
    
    func setBackBarButtonItem(title: String? = nil) {
        let temporaryBarButtonItem = UIBarButtonItem()
        temporaryBarButtonItem.title = title ?? ""
        navigationItem.backBarButtonItem = temporaryBarButtonItem
    }
    
    func pushWithHidesBottomBar(to controller: UIViewController, animated: Bool = true) {
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: animated)
    }
    
    @discardableResult
    func pop(animated: Bool = true) -> UIViewController? {
        return navigationController?.popViewController(animated: animated)
    }
    
    @discardableResult
    func pop(to aClass: AnyClass) -> UIViewController {
        var vc = self
        self.navigationController?.viewControllers.forEach({ (controller) in
            if controller.isKind(of: aClass) {
                self.navigationController?.popToViewController(controller, animated: true)
                vc = controller
            }
        })
        return vc
    }
    
}

private var _easyBarButtonItemStruct: Void?

public extension UIBarButtonItem {
    
    private struct EasyStruct {
        var handler: (() -> Void)?
    }
    
    private var easyStruct: EasyStruct? {
        get {
            return objc_getAssociatedObject(self, &_easyBarButtonItemStruct) as? EasyStruct
        }
        set {
            objc_setAssociatedObject(self, &_easyBarButtonItemStruct, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    @objc private func tapAction() {
        easyStruct?.handler?()
    }
    
    func tap(_ handler: @escaping () -> Void) {
        easyStruct = EasyStruct(handler: handler)
        target = self
        action = #selector(tapAction)
    }
    
}

public extension UINavigationItem {
    
    @discardableResult
    private func appendBarButtonItem(isRight: Bool, title: String?, image: UIImage?, attributes: [NSAttributedString.Key : Any]? = [.font: UIFont.size15], tapHandler: @escaping () -> Void) -> UINavigationItem {
        let barButtonItem = image == nil ? UIBarButtonItem(title: title, style: .done, target: nil, action: nil) : UIBarButtonItem(image: image, style: .done, target: self, action: nil)
        barButtonItem.setTitleTextAttributes(attributes, for: .normal)
        barButtonItem.setTitleTextAttributes(attributes, for: .highlighted)
        barButtonItem.tap(tapHandler)
        
        if let items = (isRight ? rightBarButtonItems : leftBarButtonItems), items.count > 0 {
            if isRight {
                rightBarButtonItems?.append(barButtonItem)
            } else {
                leftBarButtonItems?.append(barButtonItem)
            }
        } else {
            if isRight {
                rightBarButtonItem = barButtonItem
            } else {
                leftBarButtonItem = barButtonItem
            }
        }
        return self
    }
    
    @discardableResult
    func appendRightBarButtonItem(title: String, attributes: [NSAttributedString.Key : Any]? = [.font: UIFont.size15], tapHandler: @escaping () -> Void) -> UINavigationItem {
        return appendBarButtonItem(isRight: true, title: title, image: nil, attributes: attributes, tapHandler: tapHandler)
    }
    
    @discardableResult
    func appendRightBarButtonItem(image: UIImage, attributes: [NSAttributedString.Key : Any]? = [.font: UIFont.size15], tapHandler: @escaping () -> Void) -> UINavigationItem {
        return appendBarButtonItem(isRight: true, title: nil, image: image, attributes: attributes, tapHandler: tapHandler)
    }
    
    @discardableResult
    func appendLeftBarButtonItem(title: String, attributes: [NSAttributedString.Key : Any]? = [.font: UIFont.size15], tapHandler: @escaping () -> Void) -> UINavigationItem {
        return appendBarButtonItem(isRight: false, title: title, image: nil, attributes: attributes, tapHandler: tapHandler)
    }
    
    @discardableResult
    func appendLeftBarButtonItem(image: UIImage, attributes: [NSAttributedString.Key : Any]? = [.font: UIFont.size15], tapHandler: @escaping () -> Void) -> UINavigationItem {
        return appendBarButtonItem(isRight: false, title: nil, image: image, attributes: attributes, tapHandler: tapHandler)
    }
    
}

public extension UINavigationBar {
    
    /// 去掉导航背景的阴影
    @discardableResult
    func setTransparent() -> UINavigationBar {
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
        isTranslucent = false
        return self
    }
    
    /// 导航背景透明
    @discardableResult
    func setTranslucent() -> UINavigationBar {
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
        isTranslucent = true
        return self
    }
    
    @discardableResult
    func setBackgroundColor(_ color: UIColor) -> UINavigationBar {
        setBackgroundImage(color.toImage, for: .default)
        return self
    }
    
    @discardableResult
    func setTintColor(_ color: UIColor) -> UINavigationBar {
        tintColor = color
        titleTextAttributes = [.foregroundColor: tintColor]
        return self
    }
    
}

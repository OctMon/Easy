//
//  EasyValid.swift
//  Easy
//
//  Created by OctMon on 2018/9/29.
//

import Foundation

public extension String {
    
    /// 正则验证
    func validRegex(_ regex: String) -> Bool {
        let regExPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return regExPredicate.evaluate(with: self.lowercased())
    }
    
    /// 纯数字验证
    var validNumber: Bool { return validRegex("^[0-9]*$") }
    
    /// 邮箱验证
    var validEmail: Bool { return validRegex("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$") }
    
    /// 手机号验证
    var validMobilePhone: Bool { return validRegex("^(0|86|17951)?(13[0-9]|14[0-9]|15[0-9]|16[0-9]|17[0-9]|18[0-9]|19[0-9])[0-9]{8}$") }
    
    /// 电话号码验证
    var validTelephone: Bool { return validRegex("([\\d]{7,25}(?!\\d))|((\\d{3,4})-(\\d{7,8}))|((\\d{3,4})-(\\d{7,8})-(\\d{1,4}))") }
    
    /// URL网址验证
    var validURL: Bool { return validHttpUrl || validHttpsUrl }
    
    /// URL网址验证
    var validHttpsUrl: Bool {
        guard lowercased().hasPrefix("https://") else {
            return false
        }
        return URL(string: self) != nil
    }
    
    /// URL网址验证
    var validHttpUrl: Bool {
        guard lowercased().hasPrefix("http://") else {
            return false
        }
        return URL(string: self) != nil
    }
    
    /// IP地址验证
    var validIP: Bool {
        if validRegex("^(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})$") {
            for string in self.components(separatedBy: ".") {
                if string .toIntValue > 255 {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }
    
    /// 大写字母验证
    var validUppercaseLetterCharact: Bool {
        if let regular = try? NSRegularExpression(pattern: "[A-Z]") {
            return regular.numberOfMatches(in: self, options: .reportProgress, range: NSMakeRange(0, count)) > 0
        }
        return false
    }
    
    /// 小写字母验证
    var validLowercaseLetterCharact: Bool {
        if let regular = try? NSRegularExpression(pattern: "[a-z]") {
            return regular.numberOfMatches(in: self, options: .reportProgress, range: NSMakeRange(0, count)) > 0
        }
        return false
    }
    
    /// 特殊字符
    var validSpecialCharact: Bool {
        guard let range = rangeOfCharacter(from: CharacterSet(charactersIn: "~￥#&*<>《》()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$_€")) else {
            return false
        }
        if range.isEmpty {
            return false
        }
        return true
    }
    
    /// 密码验证
    ///
    /// - Parameters:
    ///   - min: 最小长度
    ///   - max: 最大长大
    ///   - includeCase: 必须包含大小写
    /// - Returns: 检测密码必须包含大写字母、小写字母、数字
    func validPasswordRegulation(min: Int = 6, max: Int = 16, includeCase: Bool = true) -> Bool {
        var casesensitive = validLowercaseLetterCharact || validUppercaseLetterCharact
        if includeCase {
            casesensitive = validLowercaseLetterCharact && validUppercaseLetterCharact
        }
        guard count >= min && count <= max && !validNumber && !validSpecialCharact && casesensitive else {
            return false
        }
        
        return true
    }
    
    /// 身份证号码验证
    var validIDCard: Bool {
        if count != 18 {
            return false
        }
        let mmdd = "(((0[13578]|1[02])(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)(0[1-9]|[12][0-9]|30))|(02(0[1-9]|[1][0-9]|2[0-8])))"
        let leapMmdd = "0229"
        let year = "(19|20)[0-9]{2}"
        let leapYear = "(19|20)(0[48]|[2468][048]|[13579][26])"
        let yearMmdd = year + mmdd
        let leapyearMmdd = leapYear + leapMmdd
        let yyyyMmdd = "((\(yearMmdd))|(\(leapyearMmdd))|(20000229))"
        let area = "(1[1-5]|2[1-3]|3[1-7]|4[1-6]|5[0-4]|6[1-5]|82|[7-9]1)[0-9]{4}"
        let regex = "\(area)\(yyyyMmdd)[0-9]{3}[0-9Xx]"
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        if predicate.evaluate(with: self) == false {
            return false
        }
        
        let chars = uppercased().map { return String($0) }
        let c1 = chars[7] .toInt!
        let c2 = (chars[6] .toInt! + chars[16] .toInt!) * 2
        let c3 = chars[9] .toInt! * 3
        let c4 = (chars[5] .toInt! + chars[15] .toInt!) * 4
        let c5 = (chars[3] .toInt! + chars[13] .toInt!) * 5
        let c6 = chars[8] .toInt! * 6
        let c7 = (chars[0] .toInt! + chars[10] .toInt!) * 7
        let c8 = (chars[4] .toInt! + chars[14] .toInt!) * 8
        let c9 = (chars[1] .toInt! + chars[11] .toInt!) * 9
        let c10 = (chars[2] .toInt! + chars[12] .toInt!) * 10
        let summary: Int = c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8 + c9 + c10
        let remainder = summary % 11
        let checkString = "10X98765432"
        let checkBit = checkString.map { return String($0) }[remainder]
        return (checkBit == chars.last)
    }
    
}

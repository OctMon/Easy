//
//  EasyError.swift
//  Easy
//
//  Created by OctMon on 2018/10/9.
//

import Foundation

public struct EasyErrorReason {
    public static var networkFailed = "网络连接错误"
    static var serverError = "服务器内部错误"
    static var empty = "暂无数据"
    static var token = "token过期"
    static var force = "版本错误"
}

public enum EasyError: Error {
    case empty(String), tokenExpired(String), forceUpdate(String), serviceError(String), networkFailed
    case unknown(String)
}

extension EasyError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .networkFailed:
            return EasyErrorReason.networkFailed
        case .empty(let reason), .tokenExpired(let reason), .forceUpdate(let reason), .serviceError(let reason), .unknown(let reason):
            return reason
        }
    }
    
}

//
//  EasyError.swift
//  Easy
//
//  Created by OctMon on 2018/10/9.
//

import Foundation

public extension EasyGlobal {
    static var errorNetwork: String?
    static var errorServer = "服务器内部错误"
    static var errorEmpty = "暂无数据"
    static var errorToken = "token过期"
    static var errorVersion = "版本错误"
}

public enum EasyError: Error {
    case empty(String), token(String), version(String), server(String), network(String)
    case unknown(String)
}

extension EasyError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .empty(let reason), .token(let reason), .version(let reason), .server(let reason), .network(let reason), .unknown(let reason):
            return reason
        }
    }
    
}

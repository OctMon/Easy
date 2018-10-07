//
//  EasyRouter.swift
//  Easy
//
//  Created by OctMon on 2018/9/29.
//

import Foundation

public struct EasyRouter {
    
    private var routers = EasyParameters()
    
    private static var shared = EasyRouter()
    
    private init() {}
    
}

public extension EasyRouter {
    
    struct Key {
        public static let className = "EasyRouter.className"
        public static let userInfo = "EasyRouter.userInfo"
    }
    
    static func registerURL(_ url: String, routerParametersHandler: @escaping (EasyParameters) -> Void) {
        shared.routers[url] = routerParametersHandler
    }
    
    static func openURL(_ url: String, routerParameters: EasyParameters) {
        (shared.routers[url] as? (EasyParameters) -> Void)?(routerParameters)
    }
    
}

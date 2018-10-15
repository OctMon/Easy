//
//  EasyRouter.swift
//  Easy
//
//  Created by OctMon on 2018/9/29.
//

import Foundation

public extension Easy {
    typealias Router = EasyRouter
}

public struct EasyRouter {
    
    private var routers = [EasyRouter.Key: Any]()
    
    private static var shared = EasyRouter()
    
    private init() { }
    
}

public extension EasyRouter {
    
    enum Key: String {
        case className = "EasyRouter.className"
        case userInfo = "EasyRouter.userInfo"
        case url = "EasyRouter.url"
    }
    
    static func registerURL(_ url: String, routerParametersHandler: @escaping ([EasyRouter.Key: Any]) -> Void) {
        if EasyRouter.shared.routers[.url] == nil {
            EasyRouter.shared.routers[.url] = EasyParameters()
        }
        var paramaters = (shared.routers[.url] as? EasyParameters)
        paramaters?[url] = routerParametersHandler
        shared.routers[.url] = paramaters
    }
    
    static func openURL(_ url: String, routerParameters: [EasyRouter.Key: Any]) {
        var paramaters = (shared.routers[.url] as? EasyParameters)
        (paramaters?[url] as? ([EasyRouter.Key: Any]) -> Void)?(routerParameters)
    }
    
}

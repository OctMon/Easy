//
//  Easy.swift
//  Easy
//
//  Created by OctMon on 2018/9/28.
//

import UIKit

public typealias EasyParameters = [String: Any]

public struct Easy {
    private init() {}
}

public extension Easy {
    typealias app = EasyApp
    typealias log = EasyLog
    typealias alert = EasyAlert
    typealias actionSheet = EasyActionSheet
    typealias global = EasyGlobal
    typealias router = EasyRouter
}

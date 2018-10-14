//
//  EasyGlobal.swift
//  Easy
//
//  Created by OctMon on 2018/9/28.
//

import UIKit

public struct EasyGlobal { }

public extension EasyGlobal {
    
    static var tint = UIColor.hex(0x8eE2323)
    static var background = UIColor.white
    static var separator = UIColor.hex(0xEBEBEB)

}

public extension EasyGlobal {
    
    static var headerStateIdle = "下拉可以刷新"
    static var headerStatePulling = "松开立即刷新"
    static var headerStateRefreshing = "正在刷新数据"
    
    static var footerStateNoMoreData = "已经全部加载"
    
}

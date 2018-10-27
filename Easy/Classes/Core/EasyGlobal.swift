//
//  EasyGlobal.swift
//  Easy
//
//  Created by OctMon on 2018/9/28.
//

import UIKit

public extension Easy {
    typealias Global = EasyGlobal
}

public struct EasyGlobal { }

public extension EasyGlobal {
    
    static var backBarButtonItemTitle: String?
    
    static var navigationBarTintColor: UIColor?
    static var navigationBarBackgroundImage: UIImage?
    static var navigationBarTitleTextAttributes: [NSAttributedString.Key : Any]?
    
    static var navigationBarIsShadowNull = false
}

public extension EasyGlobal {
    
    static var tint = UIColor.hex(0x8E2323)
    static var background = UIColor.white
    static var separator = UIColor.hex(0xEBEBEB)
    
    static var tableViewBackground = UIColor.groupTableViewBackground
    static var collectionViewBackground = UIColor.white

}

public extension EasyGlobal {
    
    static var headerStateIdle = "下拉可以刷新"
    static var headerStatePulling = "松开立即刷新"
    static var headerStateRefreshing = "正在刷新数据"
    
    static var footerStateNoMoreData = "已经全部加载"
    
}

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
    static var backBarButtonItemImage: UIImage?
    
    static var navigationBarTintColor: UIColor?
    static var navigationBarBackgroundImage: UIImage?
    static var navigationBarTitleTextAttributes: [NSAttributedString.Key : Any]?
    
    static var navigationBarIsShadowNull = false
    
    static var listViewAutoTotalPage = true
    static var listViewIgnoreTotalPage = false
    static var listViewFirstPage = 1
    static var listViewCurrentPage = 1
    static var listViewPageSize: Int?
    static var listViewNoMoreDataSize = 10
    static var listViewIncrementPage = 1
    
}

public extension EasyGlobal {
    
    static var tint = UIColor.hex(0x8E2323)
    static var background = UIColor.white
    
    static var tableViewBackgroundColor = UIColor.groupTableViewBackground
    static var tableViewSeparatorStyle: UITableViewCell.SeparatorStyle = .singleLine
    static var tableViewSeparatorInset: UIEdgeInsets = .zero
    static var tableViewSeparatorColor: UIColor = .hex(0xD7D7D7)
    
    static var collectionViewBackgroundColor = UIColor.white
    
}

public extension EasyGlobal {
    
    static var headerStateIdle = "下拉可以刷新"
    static var headerStatePulling = "松开立即刷新"
    static var headerStateRefreshing = "正在刷新数据"
    
    static var footerStateNoMoreData = "已经全部加载"
    static var footerStateLabelTextColor = UIColor.hex(0xCCCCCC)
    static var footerStateLabelFont = UIFont.size12
    static var footerRefreshHeight: CGFloat = 44
    
}

public extension EasyGlobal {
    static var errorNetwork: String?
    static var errorServer: String?
    static var errorEmpty = "暂无数据"
    static var errorToken = "token过期"
    static var errorVersion = "版本错误"
    static var errorUnknown = "未知错误"
}

public extension EasyGlobal {
    
    static var loadingText: String? = nil
    
}

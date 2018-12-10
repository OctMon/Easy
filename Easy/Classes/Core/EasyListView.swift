//
//  EasyListView.swift
//  Easy
//
//  Created by OctMon on 2018/11/8.
//

import UIKit

open class EasyListView: UIView {
    
    deinit { EasyLog.debug(toDeinit) }
    
    /// 第一页
    public lazy var firstPage: Int = EasyGlobal.tableViewFirstPage
    
    /// 当前页
    public lazy var currentPage: Int = EasyGlobal.tableViewCurrentPage
    
    /// 分页数量
    public lazy var pageSize: Int = EasyGlobal.tableViewPageSize
    
    /// 下一页增量(跳过的页数)
    public lazy var incrementPage: Int = EasyGlobal.tableViewIncrementPage
    
    /// 自动判断总页数
    public lazy var autoTotalPage: Bool = EasyGlobal.tableViewAutoTotalPage
    
    /// 忽略总页数判断
    public lazy var ignoreTotalPage: Bool = EasyGlobal.tableViewIgnoreTotalPage
    
    public lazy var list: [Any] = [Any]()
    
    lazy var requestHandler: (() -> Void)? = { return nil }()
    
    open func configure() { }
    
    public func list<T>(_ class: T.Type) -> [T] {
        return list as? [T] ?? []
    }
    
    public func topView<T>(_ view: T.Type) -> T? {
        if let topView = self.superview as? T {
            return topView
        }
        return nil
    }
    
    public var placeholders: [EasyPlaceholder]?
    
    func getAny<T>(_ dataSource: [Any], indexPath: IndexPath, numberOfSections: Int, numberOfRowsInSectionHandler: ((T, Int) -> Int)?) -> Any? {
        if numberOfSections > 0 {
            if indexPath.section < dataSource.count {
                if let any = (dataSource[indexPath.section] as? [Any]) {
                    if indexPath.row < any.count {
                        return any[indexPath.row]
                    }
                } else if let `self` = self as? T, let row = numberOfRowsInSectionHandler?(self, indexPath.section), row > 0 {
                    return dataSource[indexPath.section]
                } else if indexPath.row < dataSource.count {
                    return dataSource[indexPath.row]
                }
            }
        } else if indexPath.row < dataSource.count {
            return dataSource[indexPath.row]
        }
        return nil
    }
    
}

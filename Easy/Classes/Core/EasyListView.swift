//
//  EasyListView.swift
//  Easy
//
//  Created by OctMon on 2018/11/8.
//

import UIKit

public extension Easy {
    typealias ListView = EasyListView
}

open class EasyListView: UIView {
    
    deinit { EasyLog.debug(toDeinit) }
    
    /// 第一页
    public lazy var firstPage: Int = EasyGlobal.listViewFirstPage
    
    /// 当前页
    public lazy var currentPage: Int = EasyGlobal.listViewCurrentPage
    
    /// 分页数量
    public lazy var pageSize: Int? = EasyGlobal.listViewPageSize
    
    /// 大于等于多少条数据提示没有更多的数据
    public lazy var noMoreDataSize: Int = EasyGlobal.listViewNoMoreDataSize
    
    /// 下一页增量(跳过的页数)
    public lazy var incrementPage: Int = EasyGlobal.listViewIncrementPage
    
    /// 自动判断总页数
    public lazy var autoTotalPage: Bool = EasyGlobal.listViewAutoTotalPage
    
    /// 忽略总页数判断
    public lazy var ignoreTotalPage: Bool = EasyGlobal.listViewIgnoreTotalPage
    
    public var tableViewBackgroundColor: UIColor = EasyGlobal.tableViewBackgroundColor
    public var collectionViewBackgroundColor: UIColor = EasyGlobal.collectionViewBackgroundColor
    
    open lazy var model: Any? = nil
    
    open lazy var list: [Any] = [Any]()
    
    lazy var requestHandler: (() -> Void)? = { return nil }()
    
    open func configure() { }
    
    public func model<T>(_ class: T.Type) -> T? {
        return model as? T ?? nil
    }
    
    public func listTo<T>(_ class: T.Type) -> [T] {
        return list as? [T] ?? []
    }
    
    public func list<T>(_ class: T.Type) -> [T]? {
        return list as? [T]
    }
    
    public var placeholders: [EasyPlaceholder]?
    public var placeholderBackgroundColor: UIColor = EasyGlobal.placeholderBackgroundColor, placeholderOffset: CGFloat = 0, placeholderBringSubviews: [UIView]? = nil
    public var placeholderIsUserInteractionEnabled: Bool = EasyGlobal.placeholderIsUserInteractionEnabled
    
    func getAny<T>(_ dataSource: [Any], indexPath: IndexPath, numberOfSections: Int, numberOfRowsInSectionHandler: ((T, Int) -> Int)?) -> Any? {
        if let model = model {
            return model
        }
        var rowsInSection = 0
        if let `self` = self as? T, let rows = numberOfRowsInSectionHandler?(self, indexPath.section) {
            rowsInSection = rows
        }
        if numberOfSections == 1 && rowsInSection < 1 {
            if let row = dataSource[indexPath.section] as? [Any], indexPath.section < dataSource.count {
                return row[indexPath.row]
            }
            if indexPath.row < dataSource.count {
                return dataSource[indexPath.row]
            }
        } else if numberOfSections > 0 {
            if indexPath.section < dataSource.count {
                if let any = dataSource[indexPath.section] as? [Any] {
                    if indexPath.row < any.count {
                        return any[indexPath.row]
                    }
                } else if rowsInSection > 0 && numberOfSections == dataSource.count {
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

public extension EasyListView {
    
    func requestFirst() {
        currentPage = firstPage
        requestHandler?()
    }
    
    func addPlaceholder(_ placeholder: EasyPlaceholder) {
        var existing = placeholders ?? []
        existing.append(placeholder)
        placeholders = existing
    }
    
    func addPlaceholders(_ placeholder: [EasyPlaceholder]) {
        var existing = placeholders ?? []
        existing.append(contentsOf: placeholder)
        placeholders = existing
    }
    
}

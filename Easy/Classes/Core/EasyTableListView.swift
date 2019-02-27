//
//  EasyTableListView.swift
//  Easy
//
//  Created by OctMon on 2018/11/13.
//

import UIKit

public extension Easy {
    typealias TableListView = EasyTableListView
    typealias TableListProtocol = EasyTableListProtocol
}

private var keyTableListView: Void?

public protocol EasyTableListProtocol: class {
    func addTableListView(in: UIView, style: UITableView.Style) -> EasyTableListViewAssociatedType
    associatedtype EasyTableListViewAssociatedType: EasyTableListView
}

public extension EasyTableListProtocol {
    
    var tableView: UITableView {
        return tableListView.tableView
    }
    
    var tableModel: Any? {
        get {
            return tableListView.model
        }
        set {
            tableListView.model = newValue
        }
    }
    
    var tableList: [Any] {
        get {
            return tableListView.list
        }
        set {
            tableListView.list = newValue
        }
    }
    
    var tableListView: EasyTableListViewAssociatedType! {
        get {
            if let listView = objc_getAssociatedObject(self, &keyTableListView) as? EasyTableListViewAssociatedType {
                return listView
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &keyTableListView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @discardableResult
    func addTableListView(in view: UIView, style: UITableView.Style) -> EasyTableListViewAssociatedType {
        if tableListView == nil {
            tableListView = EasyTableListViewAssociatedType()
            view.addSubview(tableListView)
            tableListView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            tableListView.add(style: style)
            tableListView.configure()
        }
        return tableListView
    }
    
    func tableList<T>(_ class: T.Type) -> [T] {
        return tableList as? [T] ?? []
    }
    
}

open class EasyTableListView: EasyListView {
    
    private lazy var numberOfSectionsHandler: ((EasyTableListView) -> Int)? = { return nil }()
    private lazy var numberOfRowsInSectionHandler: ((EasyTableListView, Int) -> Int)? = { return nil }()
    private lazy var cellHandler: ((EasyTableListView, UITableViewCell, IndexPath, Any?) -> Void)? = { return nil }()
    private lazy var cellsHandler: ((EasyTableListView, IndexPath) -> AnyClass?)? = { return nil }()
    private lazy var didSelectRowHandler: ((EasyTableListView, IndexPath, Any?) -> Void)? = { return nil }()
    private lazy var accessoryButtonTappedForRowWithHandler: ((EasyTableListView, IndexPath, Any?) -> Void)? = { return nil }()
    
    private lazy var scrollViewDidScrollHandler: ((UIScrollView) -> Void)? = { return nil }()
    
    private var getAny = false
    
    private lazy var tableViewStyle: UITableView.Style = .plain
    
    public lazy var tableView: UITableView = {
        return UITableView(frame: frame, style: tableViewStyle).then {
            $0.backgroundColor = tableViewBackgroundColor
            $0.separatorStyle = EasyGlobal.tableViewSeparatorStyle
            $0.separatorInset = EasyGlobal.tableViewSeparatorInset
            $0.separatorColor = EasyGlobal.tableViewSeparatorColor
            $0.showsVerticalScrollIndicator = false
            $0.delegate = self
            $0.dataSource = self
            $0.keyboardDismissMode = .onDrag
            $0.sectionHeaderHeight = 5
            $0.sectionFooterHeight = 5
        }
    }()
    
    public override var tableViewBackgroundColor: UIColor {
        willSet {
            tableView.backgroundColor = newValue
        }
    }
    
}

public extension EasyTableListView {
    
    @discardableResult
    fileprivate func add(style: UITableView.Style) -> UITableView {
        tableViewStyle = style
        addSubview(tableView)
        tableView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return tableView
    }
    
    /// numberOfSections
    func setNumberOfSections(_ numberOfSectionsHandler: @escaping (EasyTableListView) -> Int, numberOfRowsInSection numberOfRowsInSectionHandler: @escaping (EasyTableListView, Int) -> Int) {
        self.numberOfSectionsHandler = numberOfSectionsHandler
        self.numberOfRowsInSectionHandler = numberOfRowsInSectionHandler
    }
    
    /// cellForRowAt & didSelectRowAt
    func register(cellClass: AnyClass?, configureCell: @escaping (EasyTableListView, UITableViewCell, IndexPath) -> Void, didSelectRow didSelectRowHandler: ((EasyTableListView, IndexPath) -> Void)?) {
        register(cellsClass: [cellClass], returnCell: { (_, _) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: didSelectRowHandler)
    }
    
    /// cellForRowAt & didSelectRowAt
    func register(cellsClass: [AnyClass?], returnCell cellsHandler: @escaping (EasyTableListView, IndexPath) -> AnyClass?, configureCell cellHandler: @escaping (EasyTableListView, UITableViewCell, IndexPath) -> Void, didSelectRow didSelectRowHandler: ((EasyTableListView, IndexPath) -> Void)?) {
        cellsClass.forEach { (cc) in
            guard let cellClass = cc else { return }
            guard let cellReuseIdentifier = cc.self?.description() else { return }
            tableView.register(cellClass, forCellReuseIdentifier: cellReuseIdentifier)
        }
        self.cellsHandler = cellsHandler
        self.cellHandler = { (listView, cell, indexPath, _) in
            cellHandler(listView, cell, indexPath)
        }
        self.didSelectRowHandler = { (listView, indexPath, _) in
            didSelectRowHandler?(listView, indexPath)
        }
    }
    
    /// cellForRowAt & didSelectRowAt
    func register<T>(_ type: T.Type, cellClass: AnyClass?, configureCell: @escaping (EasyTableListView, UITableViewCell, IndexPath, T) -> Void, didSelectRow didSelectRowHandler: ((EasyTableListView, IndexPath, T) -> Void)?) {
        register(type, cellsClass: [cellClass], returnCell: { (_, _) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: didSelectRowHandler)
    }
    
    /// cellForRowAt & didSelectRowAt
    func register<T>(_ type: T.Type, cellsClass: [AnyClass?], returnCell cellsHandler: @escaping (EasyTableListView, IndexPath) -> AnyClass?, configureCell cellHandler: @escaping (EasyTableListView, UITableViewCell, IndexPath, T) -> Void, didSelectRow didSelectRowHandler: ((EasyTableListView, IndexPath, T) -> Void)?) {
        getAny = true
        cellsClass.forEach { (cc) in
            guard let cellClass = cc else { return }
            guard let cellReuseIdentifier = cc.self?.description() else { return }
            tableView.register(cellClass, forCellReuseIdentifier: cellReuseIdentifier)
        }
        self.cellsHandler = cellsHandler
        
        self.cellHandler = { (listView, cell, indexPath, any) in
            if let t = any as? T {
                cellHandler(listView, cell, indexPath, t)
            } else {
                EasyLog.debug("info:\(T.self)转换结果为nil")
            }
        }
        
        self.didSelectRowHandler = { (listView, indexPath, any) in
            if let t = any as? T {
                didSelectRowHandler?(listView, indexPath, t)
            } else {
                EasyLog.debug("info:\(T.self)转换结果为nil")
            }
        }
    }
    
    func setAccessoryButtonTappedForRowWith(_ accessoryButtonTappedForRowWithHandler: @escaping ((EasyTableListView, IndexPath) -> Void)) {
        self.accessoryButtonTappedForRowWithHandler = { (listView, indexPath, any) in
            accessoryButtonTappedForRowWithHandler(listView, indexPath)
        }
    }
    
    func setAccessoryButtonTappedForRowWith<T>(_ type: T.Type, accessoryButtonTappedForRowWith accessoryButtonTappedForRowWithHandler: @escaping ((EasyTableListView, IndexPath, T) -> Void)) {
        self.accessoryButtonTappedForRowWithHandler = { (listView, indexPath, any) in
            if let t = any as? T {
                accessoryButtonTappedForRowWithHandler(listView, indexPath, t)
            } else {
                EasyLog.debug("info:\(T.self)转换结果为nil")
            }
        }
    }
    
}

extension EasyTableListView: UITableViewDataSource, UITableViewDelegate {
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        if let handler = numberOfSectionsHandler {
            return handler(self)
        }
        if self.list.contains(where: { ($0 as? [Any]) != nil }) {
            return list.count
        }
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let handler = numberOfRowsInSectionHandler {
            return handler(self, section)
        }
        if section < list.count {
            if let array = (self.list[section] as? [Any]) {
                return array.count
            }
        }
        return list.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cellsHandler = cellsHandler, let cellReuseIdentifier = cellsHandler(self, indexPath).self?.description() {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) else { return UITableViewCell() }
            if let cellHandler = cellHandler {
                cellHandler(self, cell, indexPath, getAny ? getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: tableView), numberOfRowsInSectionHandler: numberOfRowsInSectionHandler) : nil)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let didSelectRowHandler = didSelectRowHandler {
            didSelectRowHandler(self, indexPath, getAny ? getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: tableView), numberOfRowsInSectionHandler: numberOfRowsInSectionHandler) : nil)
        }
    }
    
    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let accessoryButtonTappedForRowWithHandler = accessoryButtonTappedForRowWithHandler {
            accessoryButtonTappedForRowWithHandler(self, indexPath, getAny ? getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: tableView), numberOfRowsInSectionHandler: numberOfRowsInSectionHandler) : nil)
        }
    }
    
}

public extension EasyTableListView {
    
    func scrollViewDidScrollHandler(_ scrollViewDidScrollHandler: @escaping (UIScrollView) -> Void) {
        self.scrollViewDidScrollHandler = scrollViewDidScrollHandler
    }
    
}

extension EasyTableListView {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScrollHandler?(scrollView)
    }
    
}

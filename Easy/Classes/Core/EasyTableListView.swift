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
        return tableListView.model
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
    
    private lazy var tableViewStyle: UITableView.Style = .plain
    
    public lazy var tableView: UITableView = {
        return UITableView(frame: frame, style: tableViewStyle).then {
            $0.backgroundColor = EasyGlobal.tableViewBackground
            $0.showsVerticalScrollIndicator = false
            $0.delegate = self
            $0.dataSource = self
            $0.keyboardDismissMode = .onDrag
            $0.sectionHeaderHeight = 5
            $0.sectionFooterHeight = 5
        }
    }()
    
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
    func register(cellClass: AnyClass?, configureCell: @escaping (EasyTableListView, UITableViewCell, IndexPath, Any) -> Void, didSelectRow didSelectRowHandler: ((EasyTableListView, IndexPath, Any) -> Void)?) {
        register(cellsClass: [cellClass], returnCell: { (_, _) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: didSelectRowHandler)
    }
    
    /// cellForRowAt & didSelectRowAt
    func register(cellsClass: [AnyClass?], returnCell cellsHandler: @escaping (EasyTableListView, IndexPath) -> AnyClass?, configureCell cellHandler: @escaping (EasyTableListView, UITableViewCell, IndexPath, Any) -> Void, didSelectRow didSelectRowHandler: ((EasyTableListView, IndexPath, Any) -> Void)?) {
        cellsClass.forEach { (cc) in
            guard let cellClass = cc else { return }
            guard let cellReuseIdentifier = cc.self?.description() else { return }
            tableView.register(cellClass, forCellReuseIdentifier: cellReuseIdentifier)
        }
        self.cellsHandler = cellsHandler
        self.cellHandler = cellHandler
        self.didSelectRowHandler = didSelectRowHandler
    }
    
    /// cellForRowAt & didSelectRowAt
    func register<T>(_ type: T.Type, cellClass: AnyClass?, configureCell: @escaping (EasyTableListView, UITableViewCell, IndexPath, T) -> Void, didSelectRow didSelectRowHandler: ((EasyTableListView, IndexPath, T) -> Void)?) {
        register(type, cellsClass: [cellClass], returnCell: { (_, _) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: didSelectRowHandler)
    }
    
    /// cellForRowAt & didSelectRowAt
    func register<T>(_ type: T.Type, cellsClass: [AnyClass?], returnCell cellsHandler: @escaping (EasyTableListView, IndexPath) -> AnyClass?, configureCell cellHandler: @escaping (EasyTableListView, UITableViewCell, IndexPath, T) -> Void, didSelectRow didSelectRowHandler: ((EasyTableListView, IndexPath, T) -> Void)?) {
        cellsClass.forEach { (cc) in
            guard let cellClass = cc else { return }
            guard let cellReuseIdentifier = cc.self?.description() else { return }
            tableView.register(cellClass, forCellReuseIdentifier: cellReuseIdentifier)
        }
        self.cellsHandler = cellsHandler
        
        self.cellHandler = { (listView, cell, indexPath, any) in
            if let t = any as? T {
                cellHandler(listView, cell, indexPath, t)
            } else if let any = any {
                EasyLog.print(any)
                EasyLog.debug("warning:类型\(T.self)转换失败")
            }
        }
        
        self.didSelectRowHandler = { (listView, indexPath, any) in
            if let t = any as? T {
                didSelectRowHandler?(listView, indexPath, t)
            } else if let any = any {
                EasyLog.print(any)
                EasyLog.debug("warning:类型\(T.self)转换失败")
            }
        }
    }
    
    func setAccessoryButtonTappedForRowWith(_ accessoryButtonTappedForRowWithHandler: ((EasyTableListView, IndexPath, Any) -> Void)?) {
        self.accessoryButtonTappedForRowWithHandler = accessoryButtonTappedForRowWithHandler
    }
    
    func setAccessoryButtonTappedForRowWith<T>(_ type: T.Type, accessoryButtonTappedForRowWith accessoryButtonTappedForRowWithHandler: ((EasyTableListView, IndexPath, T) -> Void)?) {
        self.accessoryButtonTappedForRowWithHandler = { (listView, indexPath, any) in
            if let t = any as? T {
                accessoryButtonTappedForRowWithHandler?(listView, indexPath, t)
            } else if let any = any {
                EasyLog.print(any)
                EasyLog.debug("warning:类型\(T.self)转换失败")
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
                cellHandler(self, cell, indexPath, getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: tableView), numberOfRowsInSectionHandler: numberOfRowsInSectionHandler))
            }
            return cell
        }
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let didSelectRowHandler = didSelectRowHandler {
            didSelectRowHandler(self, indexPath, getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: tableView), numberOfRowsInSectionHandler: numberOfRowsInSectionHandler))
        }
    }
    
    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let accessoryButtonTappedForRowWithHandler = accessoryButtonTappedForRowWithHandler {
            accessoryButtonTappedForRowWithHandler(self, indexPath, getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: tableView), numberOfRowsInSectionHandler: numberOfRowsInSectionHandler))
        }
    }
    
}

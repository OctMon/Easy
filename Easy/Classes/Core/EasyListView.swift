//
//  EasyListView.swift
//  Easy
//
//  Created by OctMon on 2018/11/8.
//

import UIKit

public extension Easy {
    typealias TableListView = EasyTableListView
    typealias TableListProtocol = EasyTableListProtocol
    typealias CollectionListView = EasyCollectionListView
    typealias CollectionListProtocol = EasyCollectionListProtocol
}

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
    
    lazy var tableViewRequestHandler: (() -> Void)? = { return nil }()
    lazy var collectionViewRequestHandler: (() -> Void)? = { return nil }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func configure() { }
    
    public func listTo<T>(_ class: T.Type) -> [T] {
        return list as? [T] ?? []
    }
    
    fileprivate func getAny<T>(_ dataSource: [Any], indexPath: IndexPath, numberOfSections: Int, numberOfRowsInSectionHandler: ((T, Int) -> Int)?) -> Any? {
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

private struct Key {
    static var collectionListViewKey: Void?
    static var tableListViewKey: Void?
}

public protocol EasyTableListProtocol: class {
    func addTableListView(in: UIView, style: UITableView.Style) -> UITableView!
    associatedtype EasyTableListViewAssociatedType: EasyTableListView
}

public extension EasyTableListProtocol {
    
    var tableListView: EasyTableListViewAssociatedType! {
        get {
            if let listView = objc_getAssociatedObject(self, &Key.tableListViewKey) as? EasyTableListViewAssociatedType {
                return listView
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &Key.tableListViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @discardableResult
    func addTableListView(in view: UIView, style: UITableView.Style) -> UITableView! {
        if tableListView == nil {
            tableListView = EasyTableListViewAssociatedType()
            view.addSubview(tableListView)
            tableListView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            return tableListView.add(style: style)
        }
        return nil
    }
}

open class EasyTableListView: EasyListView {
    
    private lazy var numberOfSectionsHandler: ((EasyTableListView) -> Int)? = { return nil }()
    private lazy var numberOfRowsInSectionHandler: ((EasyTableListView, Int) -> Int)? = { return nil }()
    private lazy var cellHandler: ((UITableViewCell, IndexPath, Any?) -> Void)? = { return nil }()
    private lazy var tableViewCellsHandler: ((IndexPath) -> AnyClass?)? = { return nil }()
    private lazy var didSelectRowHandler: ((IndexPath, Any?) -> Void)? = { return nil }()
    private lazy var accessoryButtonTappedForRowWithHandler: ((IndexPath, Any?) -> Void)? = { return nil }()
    
    /// must be set first
    public lazy var tableViewStyle: UITableView.Style = .plain
    
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
    func setTableView(numberOfSections numberOfSectionsHandler: @escaping (EasyTableListView) -> Int, numberOfRowsInSection numberOfRowsInSectionHandler: @escaping (EasyTableListView, Int) -> Int) {
        self.numberOfSectionsHandler = numberOfSectionsHandler
        self.numberOfRowsInSectionHandler = numberOfRowsInSectionHandler
    }
    
    /// cellForRowAt & didSelectRowAt
    func setTableViewRegister(_ cellClass: AnyClass?, configureCell: @escaping (UITableViewCell, IndexPath, Any) -> Void, didSelectRow didSelectRowHandler: ((IndexPath, Any) -> Void)?) {
        setTableViewRegister([cellClass], returnCell: { (_) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: didSelectRowHandler)
    }
    
    /// cellForRowAt & didSelectRowAt
    func setTableViewRegister(_ cellsClass: [AnyClass?], returnCell tableViewCellsHandler: @escaping (IndexPath) -> AnyClass?, configureCell cellHandler: @escaping (UITableViewCell, IndexPath, Any) -> Void, didSelectRow didSelectRowHandler: ((IndexPath, Any) -> Void)?) {
        cellsClass.forEach { (cc) in
            guard let cellClass = cc else { return }
            guard let cellReuseIdentifier = cc.self?.description() else { return }
            tableView.register(cellClass, forCellReuseIdentifier: cellReuseIdentifier)
        }
        self.tableViewCellsHandler = tableViewCellsHandler
        self.cellHandler = cellHandler
        self.didSelectRowHandler = didSelectRowHandler
    }
    
    /// cellForRowAt & didSelectRowAt
    func setTableViewRegister<T>(_ type: T.Type, cellClass: AnyClass?, configureCell: @escaping (UITableViewCell, IndexPath, T) -> Void, didSelectRow didSelectRowHandler: ((IndexPath, T) -> Void)?) {
        setTableViewRegister(type, cellsClass: [cellClass], returnCell: { (_) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: didSelectRowHandler)
    }
    
    /// cellForRowAt & didSelectRowAt
    func setTableViewRegister<T>(_ type: T.Type, cellsClass: [AnyClass?], returnCell tableViewCellsHandler: @escaping (IndexPath) -> AnyClass?, configureCell cellHandler: @escaping (UITableViewCell, IndexPath, T) -> Void, didSelectRow didSelectRowHandler: ((IndexPath, T) -> Void)?) {
        cellsClass.forEach { (cc) in
            guard let cellClass = cc else { return }
            guard let cellReuseIdentifier = cc.self?.description() else { return }
            tableView.register(cellClass, forCellReuseIdentifier: cellReuseIdentifier)
        }
        self.tableViewCellsHandler = tableViewCellsHandler
        
        self.cellHandler = { (cell, indexPath, any) in
            if let t = any as? T {
                cellHandler(cell, indexPath, t)
            } else {
                EasyLog.print(any)
                EasyLog.debug("warning:类型\(T.self)转换失败")
            }
        }
        
        self.didSelectRowHandler = { (indexPath, any) in
            if let t = any as? T {
                didSelectRowHandler?(indexPath, t)
            } else {
                EasyLog.print(any)
                EasyLog.debug("warning:类型\(T.self)转换失败")
            }
        }
    }
    
    func setTableViewAccessoryButtonTappedForRowWith(_ accessoryButtonTappedForRowWithHandler: ((IndexPath, Any) -> Void)?) {
        self.accessoryButtonTappedForRowWithHandler = accessoryButtonTappedForRowWithHandler
    }
    
    func setTableViewAccessoryButtonTappedForRowWith<T>(_ type: T.Type, accessoryButtonTappedForRowWith accessoryButtonTappedForRowWithHandler: ((IndexPath, T) -> Void)?) {
        self.accessoryButtonTappedForRowWithHandler = { (indexPath, any) in
            if let t = any as? T {
                accessoryButtonTappedForRowWithHandler?(indexPath, t)
            } else {
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
        if let tableViewCellsHandler = tableViewCellsHandler, let cellReuseIdentifier = tableViewCellsHandler(indexPath).self?.description() {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) else { return UITableViewCell() }
            if let cellHandler = cellHandler {
                cellHandler(cell, indexPath, getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: tableView), numberOfRowsInSectionHandler: numberOfRowsInSectionHandler))
            }
            return cell
        }
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let didSelectRowHandler = didSelectRowHandler {
            didSelectRowHandler(indexPath, getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: tableView), numberOfRowsInSectionHandler: numberOfRowsInSectionHandler))
        }
    }
    
    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let accessoryButtonTappedForRowWithHandler = accessoryButtonTappedForRowWithHandler {
            accessoryButtonTappedForRowWithHandler(indexPath, getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: tableView), numberOfRowsInSectionHandler: numberOfRowsInSectionHandler))
        }
    }
    
}

public protocol EasyCollectionListProtocol: class {
    func addCollectionView(in: UIView) -> UICollectionView!
    associatedtype EasyCollectionListViewAssociatedType: EasyCollectionListView
}

public extension EasyCollectionListProtocol {
    
    var collectionViewListView: EasyCollectionListViewAssociatedType! {
        get {
            if let listView = objc_getAssociatedObject(self, &Key.collectionListViewKey) as? EasyCollectionListViewAssociatedType {
                return listView
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &Key.collectionListViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @discardableResult
    func addCollectionView(in view: UIView) -> UICollectionView! {
        if collectionViewListView == nil {
            collectionViewListView = EasyCollectionListViewAssociatedType()
            view.addSubview(collectionViewListView)
            collectionViewListView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            return collectionViewListView.add()
        }
        return nil
    }
}

open class EasyCollectionListView: EasyListView {
    
    private lazy var numberOfSectionsHandler: ((EasyCollectionListView) -> Int)? = { return nil }()
    private lazy var numberOfItemsInSectionHandler: ((EasyCollectionListView, Int) -> Int)? = { return nil }()
    private lazy var cellHandler: ((UICollectionViewCell, IndexPath, Any?) -> Void)? = { return nil }()
    private lazy var cellsHandler: ((IndexPath) -> AnyClass?)? = { return nil }()
    private lazy var didSelectRowHandler: ((IndexPath, Any?) -> Void)? = { return nil }()
    private lazy var sizeForItemAtHandler: ((IndexPath, Any?) -> CGSize)? = { return nil }()
    
    public lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        return UICollectionViewFlowLayout().then {
            $0.scrollDirection = .vertical
            $0.minimumLineSpacing = 15
            $0.minimumInteritemSpacing = 15
        }
    }()
    
    public lazy var collectionViewWaterFlowLayout: EasyCollectionViewWaterFlowLayout = {
        return EasyCollectionViewWaterFlowLayout().then {
            $0.delegate = self
        }
    }()
    
    public lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewFlowLayout).then {
            $0.backgroundColor = EasyGlobal.collectionViewBackground
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.dataSource = self
            $0.delegate = self
        }
    }()

}

public extension EasyCollectionListView {
    
    @discardableResult
    fileprivate func add() -> UICollectionView {
        addSubview(collectionView)
        collectionView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return collectionView
    }
    
    /// numberOfSections
    func setCollectionView(numberOfSections numberOfSectionsHandler: @escaping (EasyCollectionListView) -> Int, numberOfRowsInSection collectionViewNumberOfRowsInSectionHandler: @escaping (EasyCollectionListView, Int) -> Int) {
        self.numberOfSectionsHandler = numberOfSectionsHandler
        self.numberOfItemsInSectionHandler = collectionViewNumberOfRowsInSectionHandler
    }
    
    /// cellForItemAt & didSelectItemAt
    func setCollectionViewRegister(_ cellClass: AnyClass?, configureCell: @escaping (UICollectionViewCell, IndexPath, Any) -> Void, didSelectRow didSelectRowHandler: ((IndexPath, Any) -> Void)?) {
        setCollectionViewRegister([cellClass], returnCell: { (_) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: didSelectRowHandler)
    }
    
    /// cellForItemAt & didSelectItemAt
    func setCollectionViewRegister(_ cellsClass: [AnyClass?], returnCell cellsHandler: @escaping (IndexPath) -> AnyClass?, configureCell cellHandler: @escaping (UICollectionViewCell, IndexPath, Any) -> Void, didSelectRow didSelectRowHandler: ((IndexPath, Any) -> Void)?) {
        cellsClass.forEach { (cc) in
            guard let cellClass = cc else { return }
            guard let cellReuseIdentifier = cc.self?.description() else { return }
            collectionView.register(cellClass, forCellWithReuseIdentifier: cellReuseIdentifier)
        }
        self.cellsHandler = cellsHandler
        self.cellHandler = cellHandler
        self.didSelectRowHandler = didSelectRowHandler
    }
    
    /// cellForItemAt & didSelectItemAt
    func setCollectionViewRegister<T>(_ type: T.Type, cellClass: AnyClass?, configureCell: @escaping (UICollectionViewCell, IndexPath, T) -> Void, didSelectRow didSelectRowHandler: ((IndexPath, T) -> Void)?) {
        setCollectionViewRegister(type, cellsClass: [cellClass], returnCell: { (_) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: didSelectRowHandler)
    }
    
    /// cellForItemAt & didSelectItemAt
    func setCollectionViewRegister<T>(_ type: T.Type, cellsClass: [AnyClass?], returnCell cellsHandler: @escaping (IndexPath) -> AnyClass?, configureCell cellHandler: @escaping (UICollectionViewCell, IndexPath, T) -> Void, didSelectRow didSelectRowHandler: ((IndexPath, T) -> Void)?) {
        cellsClass.forEach { (cc) in
            guard let cellClass = cc else { return }
            guard let cellReuseIdentifier = cc.self?.description() else { return }
            collectionView.register(cellClass, forCellWithReuseIdentifier: cellReuseIdentifier)
        }
        self.cellsHandler = cellsHandler
        
        self.cellHandler = { (cell, indexPath, any) in
            if let t = any as? T {
                cellHandler(cell, indexPath, t)
            } else {
                EasyLog.print(any)
                EasyLog.debug("warning:类型\(T.self)转换失败")
            }
        }
        
        self.didSelectRowHandler = { (indexPath, any) in
            if let t = any as? T {
                didSelectRowHandler?(indexPath, t)
            } else {
                EasyLog.print(any)
                EasyLog.debug("warning:类型\(T.self)转换失败")
            }
        }
    }
    
    func setCollectionViewSizeForItemAt(_ sizeForItemAtHandler: @escaping (IndexPath, Any?) -> CGSize) {
        self.sizeForItemAtHandler = { (indexPath, any) -> CGSize in
            return sizeForItemAtHandler(indexPath, any)
        }
    }
    
    func setCollectionViewSizeForItemAt<T>(_ type: T.Type, sizeForItemAt sizeForItemAtHandler: @escaping (IndexPath, T) -> CGSize) {
        self.sizeForItemAtHandler = { (indexPath, any) -> CGSize in
            if let t = any as? T {
                return sizeForItemAtHandler(indexPath, t)
            } else {
                EasyLog.print(any)
                EasyLog.debug("warning:类型\(T.self)转换失败")
                return .zero
            }
        }
    }
    
}

extension EasyCollectionListView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let handler = numberOfSectionsHandler {
            return handler(self)
        }
        if self.list.contains(where: { ($0 as? [Any]) != nil }) {
            return list.count
        }
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let handler = numberOfItemsInSectionHandler {
            return handler(self, section)
        }
        if section < list.count {
            if let array = (self.list[section] as? [Any]) {
                return array.count
            }
        }
        return list.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cellsHandler = cellsHandler, let cellReuseIdentifier = cellsHandler(indexPath).self?.description() {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
            if let cellHandler = cellHandler {
                cellHandler(cell, indexPath, getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: collectionView), numberOfRowsInSectionHandler: numberOfItemsInSectionHandler))
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let didSelectRowHandler = didSelectRowHandler {
            didSelectRowHandler(indexPath, getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: collectionView), numberOfRowsInSectionHandler: numberOfItemsInSectionHandler))
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let sizeForItemAtHandler = sizeForItemAtHandler {
            return sizeForItemAtHandler(indexPath, getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: collectionView), numberOfRowsInSectionHandler: numberOfItemsInSectionHandler))
        }
        return .zero
    }
    
}

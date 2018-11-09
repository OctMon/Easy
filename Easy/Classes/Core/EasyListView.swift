//
//  EasyListView.swift
//  Easy
//
//  Created by OctMon on 2018/11/8.
//

import UIKit

public extension Easy {
    typealias ListView = EasyListView
    typealias ListProtocol = EasyListProtocol
}

public protocol EasyListProtocol: class {
//    var listView: ListView { get set }
    func addListView(in: UIView) -> ListView
    
    associatedtype ListView: EasyListView
}

private struct Key {
    static var listViewKey: Void?
}

public extension EasyListProtocol {
    
    var listView: ListView! {
        get {
            if let listView = objc_getAssociatedObject(self, &Key.listViewKey) as? ListView {
                return listView
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &Key.listViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @discardableResult
    func addListView(in view: UIView) -> ListView {
        if let listView = listView {
            view.addSubview(listView)
        } else {
            listView = ListView()
            view.addSubview(listView)
        }
        
        listView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return listView
    }
}

open class EasyListView: UIView {

    deinit { EasyLog.debug(toDeinit) }
    
    public lazy var tableViewDataSource: [Any] = [Any]()
    
    private lazy var tableViewNumberOfSectionsHandler: (() -> Int)? = { return nil }()
    private lazy var tableViewNumberOfRowsInSectionHandler: ((Int) -> Int)? = { return nil }()
    private lazy var tableViewCellHandler: ((UITableViewCell, IndexPath, Any) -> Void)? = { return nil }()
    private lazy var tableViewCellsHandler: ((IndexPath) -> AnyClass?)? = { return nil }()
    private lazy var tableViewDidSelectRowHandler: ((IndexPath, Any) -> Void)? = { return nil }()
    private lazy var tableViewAccessoryButtonTappedForRowWithHandler: ((IndexPath, Any) -> Void)? = { return nil }()
    lazy var tableViewRequestHandler: (() -> Void)? = { return nil }()
    
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
    
    public lazy var collectionViewDataSource: [Any] = [Any]()

    private lazy var collectionViewNumberOfSectionsHandler: (() -> Int)? = { return nil }()
    private lazy var collectionViewNumberOfItemsInSectionHandler: ((Int) -> Int)? = { return nil }()
    private lazy var collectionViewCellHandler: ((UICollectionViewCell, IndexPath, Any) -> Void)? = { return nil }()
    private lazy var collectionViewCellsHandler: ((IndexPath) -> AnyClass?)? = { return nil }()
    private lazy var collectionViewDidSelectRowHandler: ((IndexPath, Any) -> Void)? = { return nil }()
    private lazy var collectionViewSizeForItemAtHandler: ((IndexPath, Any) -> CGSize)? = { return nil }()
    lazy var collectionViewRequestHandler: (() -> Void)? = { return nil }()
    
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func configure() { }
    
}

public extension EasyListView {
    
    @discardableResult
    func addTableView(style: UITableView.Style) -> UITableView {
        tableViewStyle = style
        addSubview(tableView)
        tableView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return tableView
    }
    
    func tableViewDataSource<T>(_ class: T.Type) -> [T] {
        return tableViewDataSource as? [T] ?? []
    }
    
    /// numberOfSections
    /**
     setTableView(numberOfSections: { [weak self] () -> Int in
     return self?.dataSource.count ?? 0
     }) { (section) -> Int in
     return 1
     }
     */
    func setTableView(numberOfSections tableViewNumberOfSectionsHandler: @escaping () -> Int, numberOfRowsInSection tableViewNumberOfRowsInSectionHandler: @escaping (Int) -> Int) {
        self.tableViewNumberOfSectionsHandler = tableViewNumberOfSectionsHandler
        self.tableViewNumberOfRowsInSectionHandler = tableViewNumberOfRowsInSectionHandler
    }
    
    /// cellForRowAt & didSelectRowAt
    /**
     ```
     setTableViewRegister(TableViewCell.self, configureCell: { (cell, _, any) in
     cell.textLabel?.text = any as? String
     }) { [weak self] (indexPath, any) in
     // dosomething
     }
     ```
     */
    func setTableViewRegister(_ cellClass: AnyClass?, configureCell: @escaping (UITableViewCell, IndexPath, Any) -> Void, didSelectRow tableViewDidSelectRowHandler: ((IndexPath, Any) -> Void)?) {
        setTableViewRegister([cellClass], returnCell: { (_) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: tableViewDidSelectRowHandler)
    }
    
    /// cellForRowAt & didSelectRowAt
    /**
     setTableViewRegister([TableViewCell.self, TestCell.self], returnCell: { (indexPath) -> AnyClass? in
     switch indexPath.row {
     case 0:
     return TableViewCell.self
     default:
     return TestCell.self
     }
     }, configureCell: { (cell, _, any) in
     cell.textLabel?.text = (any as? Model)?.name
     }) { [weak self] (indexPath, any) in
     // dosomething
     }
     */
    func setTableViewRegister(_ cellsClass: [AnyClass?], returnCell tableViewCellsHandler: @escaping (IndexPath) -> AnyClass?, configureCell tableViewCellHandler: @escaping (UITableViewCell, IndexPath, Any) -> Void, didSelectRow tableViewDidSelectRowHandler: ((IndexPath, Any) -> Void)?) {
        cellsClass.forEach { (cc) in
            guard let cellClass = cc else { return }
            guard let cellReuseIdentifier = cc.self?.description() else { return }
            tableView.register(cellClass, forCellReuseIdentifier: cellReuseIdentifier)
        }
        self.tableViewCellsHandler = tableViewCellsHandler
        self.tableViewCellHandler = tableViewCellHandler
        self.tableViewDidSelectRowHandler = tableViewDidSelectRowHandler
    }
    
    /// cellForRowAt & didSelectRowAt
    /**
     ```
     setTableViewRegister(String.self, cellClass: TableViewCell.self, configureCell: { (cell, _, any) in
     cell.textLabel?.text = any as? String
     }) { [weak self] (indexPath, any) in
     // dosomething
     }
     ```
     */
    func setTableViewRegister<T>(_ type: T.Type, cellClass: AnyClass?, configureCell: @escaping (UITableViewCell, IndexPath, T) -> Void, didSelectRow tableViewDidSelectRowHandler: ((IndexPath, T) -> Void)?) {
        setTableViewRegister(type, cellsClass: [cellClass], returnCell: { (_) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: tableViewDidSelectRowHandler)
    }
    
    /// cellForRowAt & didSelectRowAt
    /**
     setTableViewRegister(String.self, cellsClass: [TableViewCell.self, TestCell.self], returnCell: { (indexPath) -> AnyClass? in
     switch indexPath.row {
     case 0:
     return TableViewCell.self
     default:
     return TestCell.self
     }
     }, configureCell: { (cell, _, any) in
     cell.textLabel?.text = (any as? Model)?.name
     }) { [weak self] (indexPath, any) in
     // dosomething
     }
     */
    func setTableViewRegister<T>(_ type: T.Type, cellsClass: [AnyClass?], returnCell tableViewCellsHandler: @escaping (IndexPath) -> AnyClass?, configureCell tableViewCellHandler: @escaping (UITableViewCell, IndexPath, T) -> Void, didSelectRow tableViewDidSelectRowHandler: ((IndexPath, T) -> Void)?) {
        cellsClass.forEach { (cc) in
            guard let cellClass = cc else { return }
            guard let cellReuseIdentifier = cc.self?.description() else { return }
            tableView.register(cellClass, forCellReuseIdentifier: cellReuseIdentifier)
        }
        self.tableViewCellsHandler = tableViewCellsHandler
        
        self.tableViewCellHandler = { (cell, indexPath, any) in
            if let t = any as? T {
                tableViewCellHandler(cell, indexPath, t)
            } else {
                EasyLog.print(any)
                EasyLog.print("warning:类型T转换失败")
            }
        }
        
        self.tableViewDidSelectRowHandler = { (indexPath, any) in
            if let t = any as? T {
                tableViewDidSelectRowHandler?(indexPath, t)
            } else {
                EasyLog.print(any)
                EasyLog.print("warning:类型T转换失败")
            }
        }
    }
    
    func setTableViewAccessoryButtonTappedForRowWith(_ tableViewAccessoryButtonTappedForRowWithHandler: ((IndexPath, Any) -> Void)?) {
        self.tableViewAccessoryButtonTappedForRowWithHandler = tableViewAccessoryButtonTappedForRowWithHandler
    }
    
    func setTableViewAccessoryButtonTappedForRowWith<T>(_ type: T.Type, accessoryButtonTappedForRowWith tableViewAccessoryButtonTappedForRowWithHandler: ((IndexPath, T) -> Void)?) {
        self.tableViewAccessoryButtonTappedForRowWithHandler = { (indexPath, any) in
            if let t = any as? T {
                tableViewAccessoryButtonTappedForRowWithHandler?(indexPath, t)
            } else {
                EasyLog.print(any)
                EasyLog.print("warning:类型T转换失败")
            }
        }
    }
    
}

extension EasyListView: UITableViewDataSource, UITableViewDelegate {
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        if let handler = tableViewNumberOfSectionsHandler {
            return handler()
        }
        if self.tableViewDataSource.contains(where: { ($0 as? [Any]) != nil }) {
            return tableViewDataSource.count
        }
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let handler = tableViewNumberOfRowsInSectionHandler {
            return handler(section)
        }
        if section < tableViewDataSource.count {
            if let array = (self.tableViewDataSource[section] as? [Any]) {
                return array.count
            }
        }
        return tableViewDataSource.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let tableViewCellsHandler = tableViewCellsHandler, let cellReuseIdentifier = tableViewCellsHandler(indexPath).self?.description() {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) else { return UITableViewCell() }
            if numberOfSections(in: tableView) > 0 {
                if indexPath.section < tableViewDataSource.count {
                    if let any = (tableViewDataSource[indexPath.section] as? [Any]) {
                        if indexPath.row < any.count {
                            tableViewCellHandler?(cell, indexPath, any[indexPath.row])
                        }
                    } else if let row = tableViewNumberOfRowsInSectionHandler?(indexPath.section), row > 0 {
                        tableViewCellHandler?(cell, indexPath, tableViewDataSource[indexPath.section])
                    } else if indexPath.row < tableViewDataSource.count {
                        tableViewCellHandler?(cell, indexPath, tableViewDataSource[indexPath.row])
                    }
                }
            } else if indexPath.row < tableViewDataSource.count {
                tableViewCellHandler?(cell, indexPath, tableViewDataSource[indexPath.row])
            }
            return cell
        }
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let tableViewDidSelectRowHandler = tableViewDidSelectRowHandler {
            if numberOfSections(in: tableView) > 0 {
                if indexPath.section < tableViewDataSource.count {
                    if let any = (tableViewDataSource[indexPath.section] as? [Any]) {
                        if indexPath.row < any.count {
                            tableViewDidSelectRowHandler(indexPath, any[indexPath.row])
                        }
                    } else if let row = tableViewNumberOfRowsInSectionHandler?(indexPath.section), row > 0 {
                        tableViewDidSelectRowHandler(indexPath, tableViewDataSource[indexPath.section])
                    } else if indexPath.row < tableViewDataSource.count {
                        tableViewDidSelectRowHandler(indexPath, tableViewDataSource[indexPath.row])
                    }
                }
            } else if indexPath.row < tableViewDataSource.count {
                tableViewDidSelectRowHandler(indexPath, tableViewDataSource[indexPath.row])
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let tableViewAccessoryButtonTappedForRowWithHandler = tableViewAccessoryButtonTappedForRowWithHandler {
            if numberOfSections(in: tableView) > 0 {
                if indexPath.section < tableViewDataSource.count {
                    if let any = (tableViewDataSource[indexPath.section] as? [Any]) {
                        if indexPath.row < any.count {
                            tableViewAccessoryButtonTappedForRowWithHandler(indexPath, any[indexPath.row])
                        }
                    } else if let row = tableViewNumberOfRowsInSectionHandler?(indexPath.section), row > 0 {
                        tableViewAccessoryButtonTappedForRowWithHandler(indexPath, tableViewDataSource[indexPath.section])
                    } else if indexPath.row < tableViewDataSource.count {
                        tableViewAccessoryButtonTappedForRowWithHandler(indexPath, tableViewDataSource[indexPath.row])
                    }
                }
            } else if indexPath.row < tableViewDataSource.count {
                tableViewAccessoryButtonTappedForRowWithHandler(indexPath, tableViewDataSource[indexPath.row])
            }
        }
    }
    
}

public extension EasyListView {
    
    @discardableResult
    func addCollectionView(layout: UICollectionViewLayout) -> UICollectionView {
        collectionView.collectionViewLayout = layout
        addSubview(collectionView)
        collectionView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return collectionView
    }
    
    func collectionViewDataSource<T>(_ class: T.Type) -> [T] {
        return collectionViewDataSource as? [T] ?? []
    }
    
    /// numberOfSections
    /**
     setCollectionView(numberOfSections: { [weak self] () -> Int in
     return self?.dataSource.count ?? 0
     }) { (section) -> Int in
     return 1
     }
     */
    func setCollectionView(numberOfSections collectionViewNumberOfSectionsHandler: @escaping () -> Int, numberOfRowsInSection collectionViewNumberOfRowsInSectionHandler: @escaping (Int) -> Int) {
        self.collectionViewNumberOfSectionsHandler = collectionViewNumberOfSectionsHandler
        self.collectionViewNumberOfItemsInSectionHandler = collectionViewNumberOfRowsInSectionHandler
    }
    
    /**
     ```
     setCollectionViewRegister(CCell.self, configureCell: { (cell, _, any) in
     cell.textLabel?.text = any as? String
     }) { [weak self] (indexPath, any) in
     // dosomething
     }
     ```
     */
    func setCollectionViewRegister(_ cellClass: AnyClass?, configureCell: @escaping (UICollectionViewCell, IndexPath, Any) -> Void, didSelectRow collectionViewDidSelectRowHandler: ((IndexPath, Any) -> Void)?) {
        setCollectionViewRegister([cellClass], returnCell: { (_) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: collectionViewDidSelectRowHandler)
    }
    
    /// cellForItemAt & didSelectItemAt
    /**
     setCollectionViewRegister([CollectionViewCell.self, TestCollectionViewCell.self], returnCell: { (indexPath) -> AnyClass? in
     switch indexPath.row {
     case 0:
     return CollectionViewCell.self
     default:
     return TestCollectionViewCell.self
     }
     }, configureCell: { (cell, _, any) in
     cell.textLabel?.text = (any as? Model)?.name
     }) { [weak self] (indexPath, any) in
     // dosomething
     }
     */
    func setCollectionViewRegister(_ cellsClass: [AnyClass?], returnCell collectionViewCellsHandler: @escaping (IndexPath) -> AnyClass?, configureCell collectionViewCellHandler: @escaping (UICollectionViewCell, IndexPath, Any) -> Void, didSelectRow collectionViewDidSelectRowHandler: ((IndexPath, Any) -> Void)?) {
        cellsClass.forEach { (cc) in
            guard let cellClass = cc else { return }
            guard let cellReuseIdentifier = cc.self?.description() else { return }
            collectionView.register(cellClass, forCellWithReuseIdentifier: cellReuseIdentifier)
        }
        self.collectionViewCellsHandler = collectionViewCellsHandler
        self.collectionViewCellHandler = collectionViewCellHandler
        self.collectionViewDidSelectRowHandler = collectionViewDidSelectRowHandler
    }
    
    /**
     ```
     setCollectionViewRegister(String.self, cellClass: CCell.self, configureCell: { (cell, _, any) in
     cell.textLabel?.text = any as? String
     }) { [weak self] (indexPath, any) in
     // dosomething
     }
     ```
     */
    func setCollectionViewRegister<T>(_ type: T.Type, cellClass: AnyClass?, configureCell: @escaping (UICollectionViewCell, IndexPath, T) -> Void, didSelectRow collectionViewDidSelectRowHandler: ((IndexPath, T) -> Void)?) {
        setCollectionViewRegister(type, cellsClass: [cellClass], returnCell: { (_) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: collectionViewDidSelectRowHandler)
    }
    
    /// cellForItemAt & didSelectItemAt
    /**
     setCollectionViewRegister(String.self, cellsClass: [CollectionViewCell.self, TestCollectionViewCell.self], returnCell: { (indexPath) -> AnyClass? in
     switch indexPath.row {
     case 0:
     return CollectionViewCell.self
     default:
     return TestCollectionViewCell.self
     }
     }, configureCell: { (cell, _, any) in
     cell.textLabel?.text = (any as? Model)?.name
     }) { [weak self] (indexPath, any) in
     // dosomething
     }
     */
    func setCollectionViewRegister<T>(_ type: T.Type, cellsClass: [AnyClass?], returnCell collectionViewCellsHandler: @escaping (IndexPath) -> AnyClass?, configureCell collectionViewCellHandler: @escaping (UICollectionViewCell, IndexPath, T) -> Void, didSelectRow collectionViewDidSelectRowHandler: ((IndexPath, T) -> Void)?) {
        cellsClass.forEach { (cc) in
            guard let cellClass = cc else { return }
            guard let cellReuseIdentifier = cc.self?.description() else { return }
            collectionView.register(cellClass, forCellWithReuseIdentifier: cellReuseIdentifier)
        }
        self.collectionViewCellsHandler = collectionViewCellsHandler
        
        self.collectionViewCellHandler = { (cell, indexPath, any) in
            if let t = any as? T {
                collectionViewCellHandler(cell, indexPath, t)
            } else {
                EasyLog.print(any)
                EasyLog.print("warning:类型T转换失败")
            }
        }
        
        self.collectionViewDidSelectRowHandler = { (indexPath, any) in
            if let t = any as? T {
                collectionViewDidSelectRowHandler?(indexPath, t)
            } else {
                EasyLog.print(any)
                EasyLog.print("warning:类型T转换失败")
            }
        }
    }
    
    func setCollectionViewSizeForItemAt(_ collectionViewSizeForItemAtHandler: @escaping (IndexPath, Any) -> CGSize) {
        self.collectionViewSizeForItemAtHandler = { (indexPath, any) -> CGSize in
            return collectionViewSizeForItemAtHandler(indexPath, any) 
        }
    }
    
    func setCollectionViewSizeForItemAt<T>(_ type: T.Type, sizeForItemAt collectionViewSizeForItemAtHandler: @escaping (IndexPath, T) -> CGSize) {
        self.collectionViewSizeForItemAtHandler = { (indexPath, any) -> CGSize in
            if let t = any as? T {
                return collectionViewSizeForItemAtHandler(indexPath, t) 
            } else {
                EasyLog.print(any)
                EasyLog.print("warning:类型T转换失败")
                return .zero
            }
        }
    }
    
}

extension EasyListView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let handler = collectionViewNumberOfSectionsHandler {
            return handler()
        }
        if self.collectionViewDataSource.contains(where: { ($0 as? [Any]) != nil }) {
            return collectionViewDataSource.count
        }
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let handler = collectionViewNumberOfItemsInSectionHandler {
            return handler(section)
        }
        if section < collectionViewDataSource.count {
            if let array = (self.collectionViewDataSource[section] as? [Any]) {
                return array.count
            }
        }
        return collectionViewDataSource.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let collectionViewCellsHandler = collectionViewCellsHandler, let cellReuseIdentifier = collectionViewCellsHandler(indexPath).self?.description() {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
            if numberOfSections(in: collectionView) > 0 {
                if indexPath.section < collectionViewDataSource.count {
                    if let any = (collectionViewDataSource[indexPath.section] as? [Any]) {
                        if indexPath.row < any.count {
                            collectionViewCellHandler?(cell, indexPath, any[indexPath.row])
                        }
                    } else if let row = collectionViewNumberOfItemsInSectionHandler?(indexPath.section), row > 0 {
                        collectionViewCellHandler?(cell, indexPath, collectionViewDataSource[indexPath.section])
                    } else if indexPath.row < collectionViewDataSource.count {
                        collectionViewCellHandler?(cell, indexPath, collectionViewDataSource[indexPath.row])
                    }
                }
            } else if indexPath.row < collectionViewDataSource.count {
                collectionViewCellHandler?(cell, indexPath, collectionViewDataSource[indexPath.row])
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let collectionViewDidSelectRowHandler = collectionViewDidSelectRowHandler {
            if numberOfSections(in: collectionView) > 0 {
                if indexPath.section < collectionViewDataSource.count {
                    if let any = (collectionViewDataSource[indexPath.section] as? [Any]) {
                        if indexPath.row < any.count {
                            collectionViewDidSelectRowHandler(indexPath, any[indexPath.row])
                        }
                    } else if let row = collectionViewNumberOfItemsInSectionHandler?(indexPath.section), row > 0 {
                        collectionViewDidSelectRowHandler(indexPath, collectionViewDataSource[indexPath.section])
                    } else if indexPath.row < collectionViewDataSource.count {
                        collectionViewDidSelectRowHandler(indexPath, collectionViewDataSource[indexPath.row])
                    }
                }
            } else if indexPath.row < collectionViewDataSource.count {
                collectionViewDidSelectRowHandler(indexPath, collectionViewDataSource[indexPath.row])
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let collectionViewSizeForItemAtHandler = collectionViewSizeForItemAtHandler {
            if numberOfSections(in: collectionView) > 0 {
                if indexPath.section < collectionViewDataSource.count {
                    if let any = (collectionViewDataSource[indexPath.section] as? [Any]) {
                        if indexPath.row < any.count {
                            return collectionViewSizeForItemAtHandler(indexPath, any[indexPath.row])
                        }
                    } else if let row = collectionViewNumberOfItemsInSectionHandler?(indexPath.section), row > 0 {
                        return collectionViewSizeForItemAtHandler(indexPath, collectionViewDataSource[indexPath.section])
                    } else if indexPath.row < collectionViewDataSource.count {
                        return collectionViewSizeForItemAtHandler(indexPath, collectionViewDataSource[indexPath.row])
                    }
                }
            } else if indexPath.row < collectionViewDataSource.count {
                return collectionViewSizeForItemAtHandler(indexPath, collectionViewDataSource[indexPath.row])
            }
        }
        return .zero
    }
    
}

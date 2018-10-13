//
//  EasyBaseViewController.swift
//  Easy
//
//  Created by OctMon on 2018/10/11.
//

import UIKit

public extension Easy {
    typealias BaseViewController = EasyBaseViewController
}

open class EasyBaseViewController: UIViewController {
    
    deinit { Easy.log.debug(toDeinit) }
    
    private lazy var tableViewNumberOfSectionsHandler: (() -> Int)? = { return nil }()
    private lazy var tableViewNumberOfRowsInSectionHandler: ((Int) -> Int)? = { return nil }()
    private lazy var tableViewCellHandler: ((UITableViewCell, IndexPath, Any) -> Void)? = { return nil }()
    private lazy var tableViewCellsHandler: ((IndexPath) -> AnyClass?)? = { return nil }()
    private lazy var tableViewDidSelectRowHandler: ((IndexPath, Any) -> Void)? = { return nil }()
    
    private lazy var collectionViewNumberOfSectionsHandler: (() -> Int)? = { return nil }()
    private lazy var collectionViewNumberOfItemsInSectionHandler: ((Int) -> Int)? = { return nil }()
    private lazy var collectionViewCellHandler: ((UICollectionViewCell, IndexPath, Any) -> Void)? = { return nil }()
    private lazy var collectionViewCellsHandler: ((IndexPath) -> AnyClass?)? = { return nil }()
    private lazy var collectionViewDidSelectRowHandler: ((IndexPath, Any) -> Void)? = { return nil }()
    
    /// 第一页
    public lazy var firstPage: Int = 1
    
    /// 当前页
    public lazy var currentPage: Int = 1
    
    /// 下一页增量(跳过的页数)
    public lazy var incrementPage: Int = 1
    
    /// 忽略总页数判断
    public lazy var ignoreTotalPage: Bool = false
    
    public lazy var dataSource: [Any] = [Any]()
    
    /// must be set first
    public lazy var tableViewStyle: UITableView.Style = .plain
    
    public lazy var tableView: UITableView = {
        return UITableView(frame: view.frame, style: tableViewStyle).then {
            view.addSubview($0)
            $0.snp.makeConstraints({ (make) in
                make.edges.equalTo(view)
            })
            $0.backgroundColor = UIColor.clear
            $0.showsVerticalScrollIndicator = false
            $0.delegate = self
            $0.dataSource = self
            $0.keyboardDismissMode = .onDrag
            $0.sectionHeaderHeight = 5
            $0.sectionFooterHeight = 5
        }
    }()
    
    public lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        return UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
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
            view.addSubview($0)
            $0.snp.makeConstraints({ (make) in
                make.edges.equalTo(view)
            })
            $0.backgroundColor = UIColor.clear
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.dataSource = self
            $0.delegate = self
        }
    }()
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = EasyGlobal.background
        
        configure()
    }
    
    open func configure() { }
    
    open func request() { }

}

public extension EasyBaseViewController {
    
    /// numberOfSections
    /**
     setTableView(numberOfSections: { () -> Int in
         return self.dataSource.count
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
    
    /// numberOfSections
    /**
     setCollectionView(numberOfSections: { () -> Int in
         return self.dataSource.count
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
     setCollectionViewRegister(CCell.self, layout: collectionViewWaterFlowLayout, configureCell: { (cell, _, any) in
         cell.textLabel?.text = any as? String
     }) { [weak self] (indexPath, any) in
         // dosomething
     }
     ```
     */
    func setCollectionViewRegister(_ cellClass: AnyClass?, layout: UICollectionViewLayout, configureCell: @escaping (UICollectionViewCell, IndexPath, Any) -> Void, didSelectRow collectionViewDidSelectRowHandler: ((IndexPath, Any) -> Void)?) {
        setCollectionViewRegister([cellClass], layout: layout, returnCell: { (_) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: collectionViewDidSelectRowHandler)
    }
    
    /// cellForItemAt & didSelectItemAt
    /**
     setCollectionViewRegister([CollectionViewCell.self, TestCollectionViewCell.self], layout: collectionViewWaterFlowLayout, returnCell: { (indexPath) -> AnyClass? in
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
    func setCollectionViewRegister(_ cellsClass: [AnyClass?], layout: UICollectionViewLayout, returnCell collectionViewCellsHandler: @escaping (IndexPath) -> AnyClass?, configureCell collectionViewCellHandler: @escaping (UICollectionViewCell, IndexPath, Any) -> Void, didSelectRow collectionViewDidSelectRowHandler: ((IndexPath, Any) -> Void)?) {
        collectionView.collectionViewLayout = layout
        cellsClass.forEach { (cc) in
            guard let cellClass = cc else { return }
            guard let cellReuseIdentifier = cc.self?.description() else { return }
            collectionView.register(cellClass, forCellWithReuseIdentifier: cellReuseIdentifier)
        }
        self.collectionViewCellsHandler = collectionViewCellsHandler
        self.collectionViewCellHandler = collectionViewCellHandler
        self.collectionViewDidSelectRowHandler = collectionViewDidSelectRowHandler
    }
    
}

extension EasyBaseViewController: UITableViewDataSource, UITableViewDelegate {
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewNumberOfSectionsHandler?() ?? 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewNumberOfRowsInSectionHandler?(section) ?? dataSource.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let tableViewCellsHandler = tableViewCellsHandler, let cellReuseIdentifier = tableViewCellsHandler(indexPath).self?.description() {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) else { return UITableViewCell() }
            if numberOfSections(in: tableView) > 1 {
                tableViewCellHandler?(cell, indexPath, dataSource[indexPath.section])
            } else {
                tableViewCellHandler?(cell, indexPath, dataSource[indexPath.row])
            }
            return cell
        }
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let tableViewDidSelectRowHandler = tableViewDidSelectRowHandler {
            if numberOfSections(in: tableView) > 1 {
                tableViewDidSelectRowHandler(indexPath, dataSource[indexPath.section])
            } else {
                tableViewDidSelectRowHandler(indexPath, dataSource[indexPath.row])
            }
        }
    }

}

extension EasyBaseViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionViewNumberOfSectionsHandler?() ?? 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewNumberOfItemsInSectionHandler?(section) ?? dataSource.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let collectionViewCellsHandler = collectionViewCellsHandler, let cellReuseIdentifier = collectionViewCellsHandler(indexPath).self?.description() {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
            if numberOfSections(in: collectionView) > 1 {
                collectionViewCellHandler?(cell, indexPath, dataSource[indexPath.section])
            } else {
                collectionViewCellHandler?(cell, indexPath, dataSource[indexPath.row])
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let collectionViewDidSelectRowHandler = collectionViewDidSelectRowHandler {
            if numberOfSections(in: collectionView) > 1 {
                collectionViewDidSelectRowHandler(indexPath, dataSource[indexPath.section])
            } else {
                collectionViewDidSelectRowHandler(indexPath, dataSource[indexPath.row])
            }
        }
    }
    
}

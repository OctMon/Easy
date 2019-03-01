//
//  EasyCollectionListView.swift
//  Easy
//
//  Created by OctMon on 2018/11/13.
//

import UIKit

public extension Easy {
    typealias CollectionListView = EasyCollectionListView
    typealias CollectionListProtocol = EasyCollectionListProtocol
}

private var keyCollectionListView: Void?

public protocol EasyCollectionListProtocol: class {
    func addCollectionView(in: UIView) -> EasyCollectionListViewAssociatedType
    associatedtype EasyCollectionListViewAssociatedType: EasyCollectionListView
}

public extension EasyCollectionListProtocol {
    
    var collectionView: UICollectionView {
        return collectionListView.collectionView
    }
    
    var flowLayout: UICollectionViewFlowLayout {
        return collectionListView.flowLayout
    }
    
    var waterFlowLayout: EasyWaterFlowLayout {
        return collectionListView.waterFlowLayout
    }
    
    var collectionModel: Any? {
        get {
            return collectionListView.model
        }
        set {
            collectionListView.model = newValue
        }
    }
    
    var collectionList: [Any] {
        get {
            return collectionListView.list
        }
        set {
            collectionListView.list = newValue
        }
    }
    
    var collectionListView: EasyCollectionListViewAssociatedType! {
        get {
            if let listView = objc_getAssociatedObject(self, &keyCollectionListView) as? EasyCollectionListViewAssociatedType {
                return listView
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &keyCollectionListView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @discardableResult
    func addCollectionView(in view: UIView) -> EasyCollectionListViewAssociatedType {
        if collectionListView == nil {
            collectionListView = EasyCollectionListViewAssociatedType()
            view.addSubview(collectionListView)
            collectionListView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            collectionListView.add()
            collectionListView.configure()
        }
        return collectionListView
    }
    
    func collectionList<T>(_ class: T.Type) -> [T] {
        return collectionList as? [T] ?? []
    }
    
}

open class EasyCollectionListView: EasyListView {
    
    private lazy var numberOfSectionsHandler: ((EasyCollectionListView) -> Int)? = { return nil }()
    private lazy var numberOfItemsInSectionHandler: ((EasyCollectionListView, Int) -> Int)? = { return nil }()
    private lazy var cellHandler: ((EasyCollectionListView, UICollectionViewCell, IndexPath, Any?) -> Void)? = { return nil }()
    private lazy var cellsHandler: ((EasyCollectionListView, IndexPath) -> AnyClass?)? = { return nil }()
    private lazy var didSelectRowHandler: ((EasyCollectionListView, IndexPath, Any?) -> Void)? = { return nil }()
    private lazy var sizeForItemAtHandler: ((EasyCollectionListView, IndexPath, Any?) -> CGSize)? = { return nil }()
    
    private lazy var scrollViewDidScrollHandler: ((UIScrollView) -> Void)? = { return nil }()
    
    private var getAny = false
    
    public lazy var flowLayout: UICollectionViewFlowLayout = {
        return UICollectionViewFlowLayout().then {
            $0.scrollDirection = .vertical
            $0.minimumLineSpacing = 15
            $0.minimumInteritemSpacing = 15
        }
    }()
    
    public lazy var waterFlowLayout: EasyWaterFlowLayout = {
        return EasyWaterFlowLayout().then {
            $0.delegate = self
        }
    }()
    
    public lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout).then {
            $0.backgroundColor = collectionViewBackgroundColor
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.dataSource = self
            $0.delegate = self
        }
    }()
    
    public override var collectionViewBackgroundColor: UIColor {
        willSet {
            collectionView.backgroundColor = newValue
        }
    }
    
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
    func setNumberOfSections(_ numberOfSectionsHandler: @escaping (EasyCollectionListView) -> Int, numberOfRowsInSection collectionViewNumberOfRowsInSectionHandler: @escaping (EasyCollectionListView, Int) -> Int) {
        self.numberOfSectionsHandler = numberOfSectionsHandler
        self.numberOfItemsInSectionHandler = collectionViewNumberOfRowsInSectionHandler
    }
    
    /// cellForItemAt & didSelectItemAt
    func register(cellClass: AnyClass?, configureCell: @escaping (EasyCollectionListView, UICollectionViewCell, IndexPath) -> Void, didSelectRow didSelectRowHandler: ((EasyCollectionListView, IndexPath) -> Void)?) {
        register(cellsClass: [cellClass], returnCell: { (_, _) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: didSelectRowHandler)
    }
    
    /// cellForItemAt & didSelectItemAt
    func register(cellsClass: [AnyClass?], returnCell cellsHandler: @escaping (EasyCollectionListView, IndexPath) -> AnyClass?, configureCell cellHandler: @escaping (EasyCollectionListView, UICollectionViewCell, IndexPath) -> Void, didSelectRow didSelectRowHandler: ((EasyCollectionListView, IndexPath) -> Void)?) {
        cellsClass.forEach { (cc) in
            guard let cellClass = cc else { return }
            guard let cellReuseIdentifier = cc.self?.description() else { return }
            collectionView.register(cellClass, forCellWithReuseIdentifier: cellReuseIdentifier)
        }
        self.cellsHandler = cellsHandler
        self.cellHandler = { (listView, cell, indexPath, _) in
            cellHandler(listView, cell, indexPath)
        }
        self.didSelectRowHandler = { (listView, indexPath, _) in
            didSelectRowHandler?(listView, indexPath)
        }
    }
    
    /// cellForItemAt & didSelectItemAt
    func register<T>(_ type: T.Type, cellClass: AnyClass?, configureCell: @escaping (EasyCollectionListView, UICollectionViewCell, IndexPath, T) -> Void, didSelectRow didSelectRowHandler: ((EasyCollectionListView, IndexPath, T) -> Void)?) {
        register(type, cellsClass: [cellClass], returnCell: { (_, _) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: didSelectRowHandler)
    }
    
    /// cellForItemAt & didSelectItemAt
    func register<T>(_ type: T.Type, cellsClass: [AnyClass?], returnCell cellsHandler: @escaping (EasyCollectionListView, IndexPath) -> AnyClass?, configureCell cellHandler: @escaping (EasyCollectionListView, UICollectionViewCell, IndexPath, T) -> Void, didSelectRow didSelectRowHandler: ((EasyCollectionListView, IndexPath, T) -> Void)?) {
        getAny = true
        cellsClass.forEach { (cc) in
            guard let cellClass = cc else { return }
            guard let cellReuseIdentifier = cc.self?.description() else { return }
            collectionView.register(cellClass, forCellWithReuseIdentifier: cellReuseIdentifier)
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
    
    func setSizeForItemAt(_ sizeForItemAtHandler: @escaping (EasyCollectionListView, IndexPath) -> CGSize) {
        self.sizeForItemAtHandler = { (listView, indexPath, any) -> CGSize in
            return sizeForItemAtHandler(listView, indexPath)
        }
    }
    
    func setSizeForItemAt<T>(_ type: T.Type, sizeForItemAt sizeForItemAtHandler: @escaping (EasyCollectionListView, IndexPath, T?) -> CGSize) {
        self.sizeForItemAtHandler = { (listView, indexPath, any) -> CGSize in
            if let t = any as? T {
                return sizeForItemAtHandler(listView, indexPath, t)
            } else {
                EasyLog.debug("info:\(T.self)转换结果为nil")
                return sizeForItemAtHandler(listView, indexPath, nil)
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
        if let cellsHandler = cellsHandler, let cellReuseIdentifier = cellsHandler(self, indexPath).self?.description() {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
            if let cellHandler = cellHandler {
                cellHandler(self, cell, indexPath, getAny ? getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: collectionView), numberOfRowsInSectionHandler: numberOfItemsInSectionHandler) : nil)
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let didSelectRowHandler = didSelectRowHandler {
            didSelectRowHandler(self, indexPath, getAny ? getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: collectionView), numberOfRowsInSectionHandler: numberOfItemsInSectionHandler) : nil)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let sizeForItemAtHandler = sizeForItemAtHandler {
            return sizeForItemAtHandler(self, indexPath, getAny ? getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: collectionView), numberOfRowsInSectionHandler: numberOfItemsInSectionHandler) : nil)
        }
        return size
    }
    
}

public extension EasyCollectionListView {
    
    func scrollViewDidScrollHandler(_ scrollViewDidScrollHandler: @escaping (UIScrollView) -> Void) {
        self.scrollViewDidScrollHandler = scrollViewDidScrollHandler
    }
    
}

extension EasyCollectionListView {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScrollHandler?(scrollView)
    }
    
}

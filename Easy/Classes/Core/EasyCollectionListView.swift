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
    func setNumberOfSections(_ numberOfSectionsHandler: @escaping (EasyCollectionListView) -> Int, numberOfRowsInSection collectionViewNumberOfRowsInSectionHandler: @escaping (EasyCollectionListView, Int) -> Int) {
        self.numberOfSectionsHandler = numberOfSectionsHandler
        self.numberOfItemsInSectionHandler = collectionViewNumberOfRowsInSectionHandler
    }
    
    /// cellForItemAt & didSelectItemAt
    func register(cellClass: AnyClass?, configureCell: @escaping (EasyCollectionListView, UICollectionViewCell, IndexPath, Any) -> Void, didSelectRow didSelectRowHandler: ((EasyCollectionListView, IndexPath, Any) -> Void)?) {
        register(cellsClass: [cellClass], returnCell: { (_, _) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: didSelectRowHandler)
    }
    
    /// cellForItemAt & didSelectItemAt
    func register(cellsClass: [AnyClass?], returnCell cellsHandler: @escaping (EasyCollectionListView, IndexPath) -> AnyClass?, configureCell cellHandler: @escaping (EasyCollectionListView, UICollectionViewCell, IndexPath, Any) -> Void, didSelectRow didSelectRowHandler: ((EasyCollectionListView, IndexPath, Any) -> Void)?) {
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
    func register<T>(_ type: T.Type, cellClass: AnyClass?, configureCell: @escaping (EasyCollectionListView, UICollectionViewCell, IndexPath, T) -> Void, didSelectRow didSelectRowHandler: ((EasyCollectionListView, IndexPath, T) -> Void)?) {
        register(type, cellsClass: [cellClass], returnCell: { (_, _) -> AnyClass? in
            return cellClass.self
        }, configureCell: configureCell, didSelectRow: didSelectRowHandler)
    }
    
    /// cellForItemAt & didSelectItemAt
    func register<T>(_ type: T.Type, cellsClass: [AnyClass?], returnCell cellsHandler: @escaping (EasyCollectionListView, IndexPath) -> AnyClass?, configureCell cellHandler: @escaping (EasyCollectionListView, UICollectionViewCell, IndexPath, T) -> Void, didSelectRow didSelectRowHandler: ((EasyCollectionListView, IndexPath, T) -> Void)?) {
        cellsClass.forEach { (cc) in
            guard let cellClass = cc else { return }
            guard let cellReuseIdentifier = cc.self?.description() else { return }
            collectionView.register(cellClass, forCellWithReuseIdentifier: cellReuseIdentifier)
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
    
    func setSizeForItemAt(_ sizeForItemAtHandler: @escaping (EasyCollectionListView, IndexPath, Any?) -> CGSize) {
        self.sizeForItemAtHandler = { (listView, indexPath, any) -> CGSize in
            return sizeForItemAtHandler(listView, indexPath, any)
        }
    }
    
    func setSizeForItemAt<T>(_ type: T.Type, sizeForItemAt sizeForItemAtHandler: @escaping (EasyCollectionListView, IndexPath, T) -> CGSize) {
        self.sizeForItemAtHandler = { (listView, indexPath, any) -> CGSize in
            if let t = any as? T {
                return sizeForItemAtHandler(listView, indexPath, t)
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
        if let cellsHandler = cellsHandler, let cellReuseIdentifier = cellsHandler(self, indexPath).self?.description() {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
            if let cellHandler = cellHandler {
                cellHandler(self, cell, indexPath, getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: collectionView), numberOfRowsInSectionHandler: numberOfItemsInSectionHandler))
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let didSelectRowHandler = didSelectRowHandler {
            didSelectRowHandler(self, indexPath, getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: collectionView), numberOfRowsInSectionHandler: numberOfItemsInSectionHandler))
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let sizeForItemAtHandler = sizeForItemAtHandler {
            return sizeForItemAtHandler(self, indexPath, getAny(list, indexPath: indexPath, numberOfSections: numberOfSections(in: collectionView), numberOfRowsInSectionHandler: numberOfItemsInSectionHandler))
        }
        return size
    }
    
}

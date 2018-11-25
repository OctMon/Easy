//
//  EasyCycleView.swift
//  Easy
//
//  Created by OctMon on 2018/11/24.
//

import UIKit

public extension Easy {
    typealias CycleView = EasyCycleView
}

public class EasyCycleView: UIView, EasyCollectionListProtocol {
    
    deinit {
        EasyLog.debug(toDeinit)
    }
    
    public typealias EasyCollectionListViewAssociatedType = ListView
    
    private var tap: ((Int) -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addCollectionView(in: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setImageURLs(_ urls: [String], placeholderImage: UIImage?, tap: @escaping (Int) -> Void) {
        collectionList = urls
        collectionListView.count = urls.count <= 0 ? urls.count : urls.count * 2
        collectionListView.placeholderImage = placeholderImage
        collectionListView.tap = tap
    }
    
    public func reload() {
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
    }
    
}

extension EasyCycleView {
    
    public class ListView: EasyCollectionListView {
        
        var count = 0
        var placeholderImage: UIImage?
        var tap: ((Int) -> Void)?
        
        public override func configure() {
            super.configure()
            
            flowLayout.do {
                $0.scrollDirection = .horizontal
                $0.minimumInteritemSpacing = 0
                $0.minimumLineSpacing = 0
            }
            collectionView.do {
                $0.isPagingEnabled = true
                $0.scrollsToTop = false
                $0.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0)
            }
            setNumberOfSections({ (_) -> Int in
                return 1
            }) { [weak self] (_, _) -> Int in
                return self?.count ?? 0
            }
            register(imageCell.self, configureCell: { [weak self] (listView, cell, indexPath, _) in
                if let cell = cell as? imageCell {
                    let offset = indexPath.item % listView.list.count
                    cell.imageView.setImage(url: listView.list(String.self)[offset], placeholderImage: self?.placeholderImage)
                }
            }) { [weak self] (listView, indexPath, _) in
                let offset = indexPath.item % listView.list.count
                self?.tap?(offset)
            }
        }
        
        private func check() {
            guard count > 1 else { return }
            if current == 0 {
                collectionView.scrollToItem(at: IndexPath(item: count / 2, section: 0), at: .centeredHorizontally, animated: false)
            } else if current == count - 1 {
                collectionView.scrollToItem(at: IndexPath(item: count / 2 - 1, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
        
        private var current: Int {
            let itemWidth = collectionView.width + flowLayout.minimumLineSpacing
            let offsetX = collectionView.contentOffset.x
            let current = itemWidth == 0 ? 0 : Int(round(offsetX / itemWidth))
            return current
        }
        
        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            check()
        }
        
    }

}

extension EasyCycleView {
    
    public class imageCell: UICollectionViewCell {
        
        let imageView = UIImageView()
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            
            contentView.addSubview(imageView)
            imageView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}

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
    
    public typealias EasyCollectionListViewAssociatedType = CollectionListView
    
    public var timeInterval: TimeInterval = 2
    
    public var pageControl = EasyPageControl()
    
    private var tap: ((Int) -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addCollectionView(in: self)
        addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(25)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setImageURLs(_ urls: [String], placeholderImage: UIImage?, tap: @escaping (Int) -> Void) {
        collectionList = urls
        collectionListView.count = urls.count <= 1 ? urls.count : urls.count * 2
        collectionListView.placeholderImage = placeholderImage
        collectionListView.tap = tap
        collectionListView.timerRunLoop()
        pageControl.numberOfPages = urls.count
    }
    
    public func reload() {
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
    }
    
}

extension EasyCycleView {
    
    public class CollectionListView: EasyCollectionListView {
        
        var count = 0
        var placeholderImage: UIImage?
        var tap: ((Int) -> Void)?
        
        private var timer: Timer?
        
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
            register(cellClass: imageCell.self, configureCell: { [weak self] (listView, cell, indexPath) in
                if let cell = cell as? imageCell {
                    let offset = indexPath.item % listView.list.count
                    #if canImport(SDWebImage) || canImport(Kingfisher)
                    cell.imageView.setImage(url: listView.listTo(String.self)[offset], placeholderImage: self?.placeholderImage)
                    #endif
                }
            }) { [weak self] (listView, indexPath) in
                let offset = indexPath.item % listView.list.count
                self?.tap?(offset)
            }
        }
        
        override public func willMove(toWindow newWindow: UIWindow?) {
            super.willMove(toWindow: newWindow)
            if newWindow != nil {
                timerRunLoop()
            } else {
                timerInvalidate()
            }
        }
        
        func timerRunLoop() {
            guard let timeInterval = superview(with: EasyCycleView.self)?.timeInterval else { return }
            guard timeInterval != 0 else { return }
            guard count > 1 else { return }
            timerInvalidate()
            timer = Timer(timeInterval: timeInterval, target: self, selector: #selector(timerRepeat), userInfo: nil, repeats: true)
            if let timer = timer {
                RunLoop.main.add(timer, forMode: .common)
            }
        }
        
        private func timerInvalidate() {
            guard timer != nil else { return }
            timer?.invalidate()
            timer = nil
        }
        
        @objc private func timerRepeat() {
            var item = current + 1
            if current == count - 1 {
                check()
                item = count / 2
            }
            collectionView.scrollToItem(at: IndexPath(item: item, section: 0), at: .centeredHorizontally, animated: true)
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
            timerInvalidate()
            check()
        }
        
        public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
            superview(with: EasyCycleView.self)?.pageControl.currentPage = current % (list.count)
        }
        
        public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            timerRunLoop()
        }
        
        public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            superview(with: EasyCycleView.self)?.pageControl.currentPage = current % (list.count)
        }
        
    }
    
}

extension EasyCycleView {
    
    class imageCell: UICollectionViewCell {
        
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

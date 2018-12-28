//
//  EasyTagListView.swift
//  Easy
//
//  Created by OctMon on 2018/11/29.
//

import UIKit

public extension Easy {
    typealias TagListView = EasyTagListView
}

public class EasyTagListView: UIView, EasyCollectionListProtocol {
    
    public typealias EasyCollectionListViewAssociatedType = CollectionListView
    
    deinit {
        EasyLog.debug(toDeinit)
    }
    
    public var font: UIFont = .size10
    public var textColor: UIColor = EasyGlobal.tint
    public var borderColor: UIColor = EasyGlobal.tint
    public var borderWidth: CGFloat = 1
    public var cornerRadius: CGFloat = 2
    public var constrainedSize: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    private var maxConstrainedHeight: CGFloat = CGFloat.greatestFiniteMagnitude
    
    public var minimumInteritemSpacing: CGFloat = 4 {
        didSet {
            waterFlowLayout.minimumInteritemSpacing = minimumInteritemSpacing
        }
    }
    public var minimumLineSpacing: CGFloat = 4 {
        didSet {
            waterFlowLayout.minimumLineSpacing = minimumLineSpacing
        }
    }
    public var sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4) {
        didSet {
            waterFlowLayout.sectionInset = sectionInset
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addCollectionView(in: self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setTags(_ tags: [String], maxConstrainedHeight: CGFloat, tap: @escaping (Int) -> Void) {
        collectionList = tags
        collectionListView.tap = tap
        self.maxConstrainedHeight = maxConstrainedHeight
        
        calcHeight()
    }
    
    public func reload() {
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
    }
    
    public func calcHeight() {
        EasyApp.runInMain(delay: 0.00001, handler: {
            let contentSize = self.collectionListView.waterFlowLayout.collectionViewContentSize
            self.snp.makeConstraints({ (make) in
                make.height.equalTo(min(self.maxConstrainedHeight, contentSize.height)).priority(.low)
            })
        })
    }
    
}

extension EasyTagListView {
    
    public class CollectionListView: EasyCollectionListView {
        
        var tap: ((Int) -> Void)?
        
        public override func configure() {
            super.configure()
            
            guard let superview = superview(with: EasyTagListView.self) else { return }
            
            waterFlowLayout.do {
                $0.flowStyle = .equalHeight
                $0.sectionInset = superview.sectionInset
                $0.minimumInteritemSpacing = superview.minimumInteritemSpacing
                $0.minimumLineSpacing = superview.minimumLineSpacing
            }
            collectionView.do {
                $0.scrollsToTop = false
                $0.collectionViewLayout = waterFlowLayout
            }
            register(String.self, cellClass: TagCell.self, configureCell: { [weak superview] (listView, cell, indexPath, tag) in
                if let cell = cell as? TagCell {
                    cell.tagButton.setTitle(tag, for: .normal)
                    if let superview = superview {
                        cell.tagButton.titleLabel?.font = superview.font
                        cell.tagButton.setTitleColor(superview.textColor, for: .normal)
                        cell.tagButton.setBackgroundBorder(superview.cornerRadius, borderColor: superview.borderColor, borderWidth: superview.borderWidth)
                        cell.tagButton.setTitle(tag, for: .normal)
                    }
                }
            }) { [weak self] (_, indexPath, _) in
                self?.tap?(indexPath.item)
            }
            
            setSizeForItemAt(String.self) { (listView, _, tag) -> CGSize in
                guard let superview = listView.superview(with: EasyTagListView.self) else { return CGSize.zero }
                let size = tag?.getSize(forConstrainedSize: superview.constrainedSize, font: superview.font) ?? .zero
                return CGSize(width: size.width + listView.waterFlowLayout.minimumLineSpacing + superview.borderWidth, height: size.height + listView.waterFlowLayout.minimumInteritemSpacing + superview.borderWidth)
            }
        }
        
    }
    
}

extension EasyTagListView {
    
    class TagCell: UICollectionViewCell {
        
        let tagButton = UIButton().then {
            $0.isUserInteractionEnabled = false
        }
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            
            contentView.addSubview(tagButton)
            tagButton.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}

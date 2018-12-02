//
//  EasyWaterFlowLayout.swift
//  Easy
//
//  Created by OctMon on 2018/10/11.
//

import UIKit

public extension Easy {
    typealias WaterFlowLayout = EasyWaterFlowLayout
}

public class EasyWaterFlowLayout: UICollectionViewFlowLayout {
    
    /// 瀑布流样式
    ///
    /// - equalWidth: 等宽不等高
    /// - equalHeight: 等高不等宽
    public enum FlowStyle {
        case equalWidth, equalHeight
    }
    
    public weak var delegate: UICollectionViewDelegateFlowLayout?
    
    public var flowStyle: FlowStyle = .equalWidth
    
    /// vertical && equalWidth 有效
    public var columnCount: Int = 2
    
    private lazy var attributes: [UICollectionViewLayoutAttributes] = {
        return []
    }()
    
    private lazy var rows: [CGFloat] = {
        return []
    }()
    
    private lazy var columns: [CGFloat] = {
        return []
    }()
    
    private lazy var maxContentWidth: CGFloat = {
        return 0
    }()
    
    private lazy var maxContentHeight: CGFloat = {
        return 0
    }()
    
}

extension EasyWaterFlowLayout {
    
    public override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        guard let delegate = delegate else { return }
        
        if scrollDirection == .vertical {
            if flowStyle == .equalWidth {
                // 设置宽无效、高有效 列数有效、行数无效
                maxContentHeight = 0
                columns.removeAll()
                for _ in 0..<columnCount {
                    columns.append(sectionInset.top)
                }
            } else {
                // 设置宽高都有效 列数和行数无效
                maxContentHeight = 0
                columns.removeAll()
                columns.append(sectionInset.top)
                
                maxContentWidth = 0
                rows.removeAll()
                rows.append(sectionInset.left)
            }
        }
        attributes.removeAll()
        
        for section in 0..<collectionView.numberOfSections {
            if let layoutAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: section)), delegate.responds(to: #selector(delegate.collectionView(_:layout:referenceSizeForHeaderInSection:))) {
                attributes.append(layoutAttributes)
            }
            for row in 0..<collectionView.numberOfItems(inSection: section) {
                if let layoutAttributes = layoutAttributesForItem(at: IndexPath(item: row, section: section)) {
                    attributes.append(layoutAttributes)
                }
            }
            if let layoutAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: section)), delegate.responds(to: #selector(delegate.collectionView(_:layout:referenceSizeForFooterInSection:))) {
                attributes.append(layoutAttributes)
            }
        }
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        layoutAttributes.frame = getHeader(forSupplementaryViewOfKind: elementKind, with: indexPath)
        return layoutAttributes
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        layoutAttributes.frame = getItem(with: indexPath)
        return layoutAttributes
    }
    
    public override var collectionViewContentSize: CGSize {
        if scrollDirection == .vertical {
            return CGSize(width: 0, height: maxContentHeight + sectionInset.bottom)
        }
        return .zero
    }
    
}

private extension EasyWaterFlowLayout {
    
    func getHeader(forSupplementaryViewOfKind elementKind: String, with indexPath: IndexPath) -> CGRect {
        guard let collectionView = collectionView else { return .zero }
        guard let delegate = delegate else { return .zero }
        if elementKind == UICollectionView.elementKindSectionHeader {
            if scrollDirection == .vertical {
                var height: CGFloat = 0
                if delegate.responds(to: #selector(delegate.collectionView(_:layout:referenceSizeForHeaderInSection:))) {
                    height = delegate.collectionView!(collectionView, layout: self, referenceSizeForHeaderInSection: indexPath.section).height
                }
                var y = maxContentHeight == 0 ? sectionInset.top : maxContentHeight
                if !delegate.responds(to: #selector(delegate.collectionView(_:layout:referenceSizeForFooterInSection:))) || delegate.collectionView!(collectionView, layout: self, referenceSizeForFooterInSection: indexPath.section).height == 0 {
                    y = maxContentHeight == 0 ? sectionInset.top : maxContentHeight + CGFloat(minimumLineSpacing)
                }
                maxContentHeight = y + height
                if flowStyle == .equalWidth {
                    columns.removeAll()
                    for _ in 0..<columnCount {
                        columns.append(maxContentHeight)
                    }
                } else {
                    rows[0] = collectionView.width
                    columns[0] = maxContentHeight
                }
                return CGRect(x: 0, y: y, width: collectionView.width, height: height)
            }
        } else {
            if scrollDirection == .vertical {
                var height: CGFloat = 0
                if delegate.responds(to: #selector(delegate.collectionView(_:layout:referenceSizeForFooterInSection:))) {
                    height = delegate.collectionView!(collectionView, layout: self, referenceSizeForFooterInSection: indexPath.section).height
                }
                let y = height == 0 ? maxContentHeight : maxContentHeight + CGFloat(minimumLineSpacing)
                maxContentHeight = y + height
                if flowStyle == .equalWidth {
                    columns.removeAll()
                    for _ in 0..<columnCount {
                        columns.append(maxContentHeight)
                    }
                } else {
                    rows[0] = collectionView.width
                    columns[0] = maxContentHeight
                }
                return CGRect(x: 0, y: y, width: collectionView.width, height: height)
            }
        }
        return .zero
    }
    
    func getItem(with indexPath: IndexPath) -> CGRect {
        guard let collectionView = collectionView else { return .zero }
        guard let delegate = delegate else { return .zero }
        if scrollDirection == .vertical {
            if flowStyle == .equalWidth {
                let width = (collectionView.width - sectionInset.left - sectionInset.right - CGFloat(columnCount - 1) * minimumInteritemSpacing) / CGFloat(columnCount)
                var height: CGFloat = 0
                if delegate.responds(to: #selector(delegate.collectionView(_:layout:sizeForItemAt:))) {
                    height = delegate.collectionView!(collectionView, layout: self, sizeForItemAt: indexPath).height
                }
                var shortIndex = 0
                var shortHeight = columns.first ?? 0
                for index in 1..<columns.count {
                    let currentHeight = columns[index]
                    if shortHeight > currentHeight {
                        shortIndex = index
                        shortHeight = currentHeight
                    }
                }
                let x = sectionInset.left + CGFloat(shortIndex) * (width + minimumInteritemSpacing)
                var y = shortHeight
                if y != sectionInset.top {
                    y += minimumLineSpacing
                }
                let frame = CGRect(x: x, y: y, width: width, height: height)
                columns[shortIndex] = frame.maxY
                let columnHeight = columns[shortIndex]
                if maxContentHeight < columnHeight {
                    maxContentHeight = columnHeight
                }
                return frame
            }
        }
        return .zero
    }
    
}

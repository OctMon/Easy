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
    /// - equalWidth: 等宽不等高(实现宽无效、高有效)
    /// - equalHeight: 等高不等宽(实现宽、高都有效)
    public enum FlowStyle {
        case equalWidth, equalHeight
    }
    
    public weak var delegate: UICollectionViewDelegateFlowLayout?
    
    public var flowStyle: FlowStyle = .equalWidth
    
    /// vertical && equalWidth || horizontal && equalHeight 有效
    public var flowCount: Int = 2
    
    private lazy var attributes: [UICollectionViewLayoutAttributes] = {
        return []
    }()
    
    private lazy var widths: [CGFloat] = {
        return []
    }()
    
    private lazy var heights: [CGFloat] = {
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
                heights.removeAll()
                for _ in 0..<flowCount {
                    heights.append(sectionInset.top)
                }
            } else {
                // 设置宽高都有效 列数和行数无效
                maxContentHeight = 0
                heights.removeAll()
                heights.append(sectionInset.top)
                
                maxContentWidth = 0
                widths.removeAll()
                widths.append(sectionInset.left)
            }
        } else {
            if flowStyle == .equalHeight {
                // 设置宽有效、高无效
                maxContentWidth = 0
                widths.removeAll()
                for _ in 0..<flowCount {
                    widths.append(sectionInset.left)
                }
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
        } else {
            return CGSize(width: maxContentWidth + sectionInset.right, height: 0)
        }
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
                    heights.removeAll()
                    for _ in 0..<flowCount {
                        heights.append(maxContentHeight)
                    }
                } else {
                    widths[0] = collectionView.width
                    heights[0] = maxContentHeight
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
                    heights.removeAll()
                    for _ in 0..<flowCount {
                        heights.append(maxContentHeight)
                    }
                } else {
                    widths[0] = collectionView.width
                    heights[0] = maxContentHeight
                }
                return CGRect(x: 0, y: y, width: collectionView.width, height: height)
            }
        }
        return .zero
    }
    
    func getItem(with indexPath: IndexPath) -> CGRect {
        guard let collectionView = collectionView else { return .zero }
        guard let delegate = delegate else { return .zero }
        var size: CGSize = .zero
        if delegate.responds(to: #selector(delegate.collectionView(_:layout:sizeForItemAt:))) {
            size = delegate.collectionView!(collectionView, layout: self, sizeForItemAt: indexPath)
        }
        if scrollDirection == .vertical {
            if flowStyle == .equalWidth {
                let width = (collectionView.width - sectionInset.left - sectionInset.right - CGFloat(flowCount - 1) * minimumInteritemSpacing) / CGFloat(flowCount)
                var shortIndex = 0
                var shortHeight = heights.first ?? 0
                for index in 1..<heights.count {
                    let currentHeight = heights[index]
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
                let frame = CGRect(x: x, y: y, width: width, height: size.height)
                heights[shortIndex] = frame.maxY
                let height = heights[shortIndex]
                if maxContentHeight < height {
                    maxContentHeight = height
                }
                return frame
            } else {
                var headerSize: CGSize = .zero
                if delegate.responds(to: #selector(delegate.collectionView(_:layout:referenceSizeForHeaderInSection:))) {
                    headerSize = delegate.collectionView!(collectionView, layout: self, referenceSizeForHeaderInSection: indexPath.section)
                }
                var x: CGFloat, y: CGFloat = 0
                let firstWidth = widths.first ?? 0
                let firstHeight = heights.first ?? 0
                if collectionView.width - firstWidth > size.width + sectionInset.right {
                    x = firstWidth == sectionInset.left ? sectionInset.left : firstWidth + minimumInteritemSpacing
                    if firstHeight == sectionInset.top {
                        y = sectionInset.top
                    } else if firstHeight == sectionInset.top + headerSize.height {
                        y = sectionInset.top + headerSize.height + minimumLineSpacing
                    } else {
                        y = firstHeight - size.height
                    }
                    widths[0] = x + size.width
                    if firstHeight == sectionInset.top || firstHeight == sectionInset.top + headerSize.height {
                        heights[0] = y + size.height
                    }
                } else {
                    x = sectionInset.left
                    y = firstHeight + minimumLineSpacing
                    widths[0] = x + size.width
                    heights[0] = y + size.height
                }
                maxContentHeight = heights.first ?? 0
                return CGRect(x: x, y: y, width: size.width, height: size.height)
            }
        } else {
            if flowStyle == .equalHeight {
                let height = (collectionView.height - sectionInset.top - sectionInset.bottom - CGFloat(flowCount - 1) * minimumLineSpacing) / CGFloat(flowCount)
                var shortIndex = 0
                var shortWidth = widths.first ?? 0
                for index in 1..<widths.count {
                    let currentWidth = widths[index]
                    if shortWidth > currentWidth {
                        shortIndex = index
                        shortWidth = currentWidth
                    }
                }
                var x = shortWidth
                let y = sectionInset.top + CGFloat(shortIndex) * (height + minimumLineSpacing)
                if x != sectionInset.left {
                    x += minimumInteritemSpacing
                }
                let frame = CGRect(x: x, y: y, width: size.width, height: height)
                widths[shortIndex] = frame.maxX
                let width = widths[shortIndex]
                if maxContentWidth < width {
                    maxContentWidth = width
                }
                return frame
            }
        }
        return .zero
    }
    
}

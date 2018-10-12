//
//  EasyCollectionViewWaterFlowLayout.swift
//  Easy
//
//  Created by OctMon on 2018/10/11.
//

import UIKit

public extension Easy {
    typealias CollectionViewWaterFlowLayout = EasyCollectionViewWaterFlowLayout
}

public class EasyCollectionViewWaterFlowLayout: UICollectionViewFlowLayout {
    
    struct AttributesInfo {
        var indexPath: IndexPath?
        var hasHeader = false
        var hasFooter = false
        var frame: CGRect?
    }
    
    class CalcInfo: NSObject {
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        var previousBottoms: [CGFloat] = []
        var bottoms: [CGFloat] = []
        
        var currentLineCount: Int = 0
        var width: CGFloat = 0
    }
    
    private var itemAttributes: [[IndexPath: UICollectionViewLayoutAttributes]] = []
    private var maxContentWidth: CGFloat = 0.0, maxContentHeight: CGFloat = 0.0
    
    public weak var delegate: UICollectionViewDelegateFlowLayout?
    
    /// 上下section的距离
    public var sectionSpacing: CGFloat = 0.0

    public convenience init(delegate: UICollectionViewDelegateFlowLayout?, minLineSpacing: CGFloat = 0, minItemSpacing: CGFloat = 0) {
        self.init()
        self.delegate = delegate
        self.minimumLineSpacing = minLineSpacing
        self.minimumInteritemSpacing = minItemSpacing
    }
    
    public override func prepare() {
        super.prepare()
        
        itemAttributes.removeAll()
        calcLayoutInfo()
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let ia = itemAttributes.filter { (attributes) -> Bool in
            return rect.intersects(attributes.values.first!.frame)
        }
        return ia.map({ $0.values.first! })
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let containerAttributes = itemAttributes.filter({ $0.keys.first == indexPath })
        return containerAttributes.first?.values.first
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let containerAttributes = itemAttributes.filter({ $0.keys.first == indexPath && $0.values.first?.representedElementCategory == .supplementaryView && $0.values.first?.representedElementKind == elementKind })
        return containerAttributes.first?.values.first
    }
    
    public override var collectionViewContentSize: CGSize {
        return CGSize(width: maxContentWidth, height: maxContentHeight)
    }
    
}

private extension EasyCollectionViewWaterFlowLayout {
    
    func calcLayoutInfo() {
        guard let collectionView = collectionView else { return }
        let calc = CalcInfo()
        calc.x = sectionInset.left
        calc.y = sectionInset.top
        calc.width = collectionView.width - sectionInset.left - sectionInset.right
        
        for section in 0 ..< collectionView.numberOfSections {
            var header = calcHeader(with: section, info: calc)
            for row in 0 ..< collectionView.numberOfItems(inSection: section) {
                calcItem(with: IndexPath(row: row, section: section), isUseSectionHeader: &header, info: calc)
            }
            calcFooter(with: section, info: calc)
        }
        
        maxContentWidth = collectionView.width - sectionInset.right - sectionInset.left
        maxContentHeight = calc.bottoms.max().or(calc.y - minimumLineSpacing) + sectionInset.bottom
    }
    
    func calcHeader(with section: Int, info: CalcInfo) -> Bool {
        if section != 0 {
            info.y = info.y + sectionSpacing
        }
        let attributes = setHeaderAttributes(with: section, offsetY: info.y)
        if attributes.hasHeader {
            info.x = sectionInset.left + attributes.frame.or(.zero).width
            info.y = info.y + attributes.frame.or(.zero).height + minimumLineSpacing
            info.bottoms.append(info.y - minimumLineSpacing)
        }
        return attributes.hasHeader
    }
    
    func calcItem(with index: IndexPath, isUseSectionHeader: inout Bool, info: CalcInfo) {
        let setSize = getItemSize(with: index)
        
        if info.x + setSize.width <= info.width {
            calcSameLine(model: info, setSize: setSize)
        } else {
            calcNewLine(model: info, setSize: setSize, useSectionHeader: &isUseSectionHeader)
        }
        setItemAttributes(with: index, fixFrame: CGRect(x: info.x, y: info.y, width: setSize.width, height: setSize.height))
        
        info.x = info.x + setSize.width
        maxContentHeight = info.bottoms.max().or(info.y)
    }
    
    func calcNewLine(model infoModel: CalcInfo, setSize: CGSize, useSectionHeader: inout Bool) {
        if useSectionHeader {
            useSectionHeader.toggle()
            
            infoModel.y = infoModel.bottoms.last.or(0) + minimumLineSpacing
            
            infoModel.bottoms.removeAll()
            infoModel.previousBottoms.removeAll()
            infoModel.bottoms.append(infoModel.y + setSize.height)
        } else {
            if infoModel.bottoms.count == 0 {
                infoModel.y = infoModel.y + minimumLineSpacing
                infoModel.bottoms.append(infoModel.x)
            } else {
                infoModel.previousBottoms = infoModel.bottoms
                infoModel.bottoms.removeAll()
                
                if infoModel.previousBottoms.count > 0 {
                    infoModel.y = infoModel.previousBottoms.first! + minimumLineSpacing
                } else {
                    infoModel.y = minimumLineSpacing
                }
                infoModel.bottoms.append(infoModel.y + setSize.height)
            }
        }
        infoModel.x = sectionInset.left
        infoModel.currentLineCount = 0
    }
    
    func calcSameLine(model infoModel: CalcInfo, setSize: CGSize) {
        infoModel.currentLineCount += 1
        
        infoModel.x = infoModel.x + self.minimumInteritemSpacing
        
        if infoModel.previousBottoms.count > 0 {
            if infoModel.previousBottoms.count == 1 {
                infoModel.y = infoModel.previousBottoms.first! + minimumLineSpacing
            } else {
                if infoModel.currentLineCount > infoModel.previousBottoms.count - 1 {
                    while infoModel.currentLineCount > infoModel.previousBottoms.count - 1 {
                        infoModel.currentLineCount -= 1
                    }
                    infoModel.y = infoModel.previousBottoms[infoModel.currentLineCount] + minimumLineSpacing
                } else {
                    infoModel.y = infoModel.previousBottoms[infoModel.currentLineCount] + minimumLineSpacing
                }
            }
        }
        
        maxContentWidth += setSize.width
        infoModel.bottoms.append(infoModel.y + setSize.height)
    }
    
    func calcFooter(with section: Int, info: CalcInfo) {
        info.y = info.bottoms.max().or(info.y) + minimumLineSpacing
        let fAttriInfo = setFooterAttributes(with: section, offsetY: info.y)
        if fAttriInfo.hasFooter {
            info.x = sectionInset.left + fAttriInfo.frame.or(.zero).width
            info.y = info.y + fAttriInfo.frame.or(.zero).height + minimumLineSpacing
            info.bottoms.append(info.y - minimumLineSpacing)
        }
    }
    
}

private extension EasyCollectionViewWaterFlowLayout {
    
    func getItemSize(with indexPath: IndexPath) -> CGSize {
        guard let delegate = delegate else {
            guard itemSize.isEmpty else { return itemSize }
            fatalError("need set itemSize")
        }
        if delegate.responds(to: #selector(delegate.collectionView(_:layout:sizeForItemAt:))) {
            return delegate.collectionView!(collectionView!, layout: self, sizeForItemAt: indexPath)
        }
        return itemSize
    }
    
    func getHeaderSize(with section: Int) -> CGSize {
        guard let delegate = delegate else {
            guard headerReferenceSize.isEmpty else { return headerReferenceSize }
            fatalError("need set headerReferenceSize")
        }
        if delegate.responds(to: #selector(delegate.collectionView(_:layout:referenceSizeForHeaderInSection:))) {
            return delegate.collectionView!(collectionView!, layout: self, referenceSizeForHeaderInSection: section)
        }
        return headerReferenceSize
    }
    
    func getFooterSize(with section: Int) -> CGSize {
        guard let delegate = delegate else {
            guard footerReferenceSize.isEmpty else {
                return footerReferenceSize
            }
            fatalError("need set footerReferenceSize")
        }
        if delegate.responds(to: #selector(delegate.collectionView(_:layout:referenceSizeForFooterInSection:))) {
            return delegate.collectionView!(collectionView!, layout: self, referenceSizeForFooterInSection: section)
        }
        return footerReferenceSize
    }
    
    func setHeaderAttributes(with section: Int, offsetY: CGFloat) -> AttributesInfo {
        let index = IndexPath(row: 0, section: section)
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: index)
        let headerSize = getHeaderSize(with: section)
        
        if headerSize.height > 0 {
            var frame = headerSize.toRect
            frame.origin.x = sectionInset.left
            frame.origin.y = offsetY
            setAttributesFrame(with: attributes, frame: frame)
            let save = [index: attributes]
            itemAttributes.append(save)
            return AttributesInfo(indexPath: index, hasHeader: true, hasFooter: false, frame: frame)
        }
        return AttributesInfo(indexPath: nil, hasHeader: false, hasFooter: false, frame: nil)
    }
    
    func setItemAttributes(with index: IndexPath, fixFrame: CGRect) {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: index)
        setAttributesFrame(with: attributes, frame: fixFrame)
        
        let save = [index: attributes]
        itemAttributes.append(save)
    }
    
    func setFooterAttributes(with section: Int, offsetY: CGFloat) -> AttributesInfo {
        let index = IndexPath(row: 0, section: section)
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: index)
        let size = getFooterSize(with: section)
        
        if size.height > 0 {
            var frame = size.toRect
            frame.origin.x = sectionInset.left
            frame.origin.y = offsetY
            setAttributesFrame(with: attributes, frame: frame)
            let save = [index: attributes]
            itemAttributes.append(save)
            return AttributesInfo(indexPath: index, hasHeader: false, hasFooter: true, frame: frame)
        }
        return AttributesInfo(indexPath: nil, hasHeader: false, hasFooter: false, frame: nil)
    }
    
    func setAttributesFrame(with attributes: UICollectionViewLayoutAttributes, frame: CGRect) {
        attributes.frame = frame
    }
    
}

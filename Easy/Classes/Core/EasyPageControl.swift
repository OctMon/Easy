//
//  EasyPageControl.swift
//  Easy
//
//  Created by OctMon on 2018/11/26.
//

import UIKit

public extension Easy {
    typealias PageControl = EasyPageControl
}

public class EasyPageControl: UIControl {
    
    /// default is 0
    public var numberOfPages: Int = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// default is 0. value pinned to 0..numberOfPages-1
    public var currentPage: Int = 0 {
        didSet {
            update()
        }
    }
    
    /// default is white
    public var currentPageIndicatorTintColor: UIColor = .white {
        didSet {
            setTint()
        }
    }
    
    /// default is gray
    public var pageIndicatorTintColor: UIColor = .gray {
        didSet {
            setTint()
        }
    }
    
    /// default is nil
    public var pageIndicatorImage: UIImage? {
        didSet {
            setTint()
        }
    }
    
    /// default is nil
    public var currentPageIndicatorImage: UIImage? {
        didSet {
            setTint()
        }
    }
    
    /// default is 8
    public var spacing: CGFloat = 8 {
        didSet {
            update()
        }
    }
    
    /// default is 6
    public var pageIndicatorSize: CGSize = CGSize(width: 6, height: 6) {
        didSet {
            update()
        }
    }
    
    /// default is nil
    public var currentPageIndicatorSize: CGSize? {
        didSet {
            update()
        }
    }
    
    /// default is 4
    public var cornerRadius: CGFloat?
    
    /// default is center
    public var alignment: Alignment = .center {
        didSet {
            update()
        }
    }
    
    private var imageViews: [UIImageView] = []
    
    private func configuration() {
        guard numberOfPages > 1 else { return }
        imageViews.forEach { $0.removeFromSuperview() }
        imageViews.removeAll()
        for index in 0 ..< numberOfPages {
            let frame = getFrame(index: index)
            let imageView = UIImageView(frame: frame)
            addSubview(imageView)
            imageViews.append(imageView)
        }
        setTint()
    }
    
    private func update() {
        for (index, imageView) in imageViews.enumerated() {
            let frame = getFrame(index: index)
            imageView.frame = frame
        }
        setTint()
    }
    
    private func setTint() {
        for (index, imageView) in imageViews.enumerated() {
            if index == currentPage {
                imageView.image = currentPageIndicatorImage
                imageView.backgroundColor = currentPageIndicatorImage == nil ? currentPageIndicatorTintColor : UIColor.clear
            } else {
                imageView.image = pageIndicatorImage
                imageView.backgroundColor = pageIndicatorImage == nil ? pageIndicatorTintColor : .clear
            }
            if let cornerRadius = cornerRadius {
                imageView.setCornerRadius(cornerRadius)
            } else {
                imageView.setCornerRadius()
            }
        }
    }
    
    private func getFrame(index: Int) -> CGRect {
        let pageWidth = pageIndicatorSize.width + spacing
        var currentPageSize = pageIndicatorSize
        if let currentPageIndicatorSize = currentPageIndicatorSize {
            currentPageSize = currentPageIndicatorSize
        }
        let currentPageWidth = currentPageSize.width + spacing
        let totalPageWidth = pageWidth * CGFloat(numberOfPages - 1) + currentPageWidth + spacing
        var orignX: CGFloat = 0
        switch alignment {
        case .center:
            orignX = (frame.size.width - totalPageWidth) / 2 + spacing
        case .left:
            orignX = spacing
        case .right:
            orignX = frame.size.width - totalPageWidth + spacing
        }
        var x: CGFloat = 0
        if index <= currentPage {
            x = orignX + CGFloat(index) * pageWidth
        } else {
            x = orignX + CGFloat(index - 1) * pageWidth + currentPageWidth
        }
        let width = index == currentPage ? currentPageSize.width : pageIndicatorSize.width
        let height = index == currentPage ? currentPageSize.height : pageIndicatorSize.height
        let y = (frame.size.height - height) / 2
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        configuration()
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil
        } else {
            return hitView
        }
    }
    
}

public extension EasyPageControl {
    
    enum Alignment {
        case center
        case left
        case right
    }
    
}

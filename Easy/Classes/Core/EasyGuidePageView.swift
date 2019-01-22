//
//  EasyGuidePageView.swift
//  Easy
//
//  Created by OctMon on 2019/1/22.
//

import UIKit

public extension Easy {
    typealias GuidePageView = EasyGuidePageView
}

public class EasyGuidePageView: UIView {
    
    public let pageControl = EasyPageControl(frame: CGRect(x: 0, y: EasyApp.screenHeight - 30, width: EasyApp.screenWidth, height: 30))
    
    let scrollView = UIScrollView(frame: EasyApp.screenBounds).then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
    }
    
    public var animateDuration: TimeInterval = 0.3
    public var swipeToExit = true
    
    public init(images: [UIImage?], skipButton: UIButton?) {
        super.init(frame: EasyApp.screenBounds)
        
        backgroundColor = UIColor.white
        addSubview(scrollView)
        scrollView.contentSize = CGSize(width: EasyApp.screenWidth * images.count.toCGFloat, height: EasyApp.screenHeight)
        scrollView.delegate = self
        
        images.enumerated().forEach { (offset, _) in
            UIImageView(frame: CGRect(x: EasyApp.screenWidth * offset.toCGFloat, y: 0, width: EasyApp.screenWidth, height: EasyApp.screenHeight)).do {
                $0.image = images[offset]
                scrollView.addSubview($0)
                
                if let button = skipButton, offset == images.count - 1 {
                    $0.addSubview(button)
                    $0.isUserInteractionEnabled = true
                    button.tap { [weak self] (_) in
                        self?.hide()
                    }
                }
            }
        }
        
        addSubview(pageControl)
        pageControl.do {
            $0.backgroundColor = .clear
            $0.numberOfPages = images.count
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func hide() {
        UIView.animate(withDuration: animateDuration, animations: {
            self.alpha = 0
        }) { (completion) in
            self.removeFromSuperview()
        }
    }
    
}

extension EasyGuidePageView: UIScrollViewDelegate {
    
    private func currentPage(scrollView: UIScrollView) -> Int {
        return Int((scrollView.contentOffset.x + scrollView.bounds.width * 0.5) / scrollView.bounds.width)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = currentPage(scrollView: scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if swipeToExit && currentPage(scrollView: scrollView) == pageControl.numberOfPages - 1 && scrollView.panGestureRecognizer.translation(in: scrollView.superview).x < 0 {
            hide()
        }
    }
    
}

public extension EasyGuidePageView {
    
    func showFullscreen(animateDuration: TimeInterval? = nil) {
        if let animateDuration = animateDuration {
            self.animateDuration = animateDuration
        }
        EasyApp.keyWindow?.addSubview(self)
    }
    
}

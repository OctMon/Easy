//
//  EasyPlaceholder.swift
//  Easy
//
//  Created by OctMon on 2018/10/12.
//

import UIKit

private var _easyPlaceholderView: Void?

public extension UIView {
    
    private var easyPlaceholderView: UIView? {
        get { return objc_getAssociatedObject(self, &_easyPlaceholderView) as? UIView }
        set { objc_setAssociatedObject(self, &_easyPlaceholderView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func showPlaceholder(attributedString: NSAttributedString?, image: UIImage? = nil, backgroundColor: UIColor = UIColor.white, offset: CGFloat = 0, bringSubviews: [UIView]? = nil, buttonProvider: ((UIButton) -> UIButton?)? = nil, buttonTap: (() -> Void)? = nil, tap: (() -> Void)? = nil) {
        guard easyPlaceholderView == nil else { return }
        easyPlaceholderView = UIView()
        guard let placeholderView = easyPlaceholderView else { return }
        addSubview(placeholderView)
        placeholderView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        placeholderView.backgroundColor = backgroundColor
        placeholderView.tap { (_) in
            tap?()
        }
        
        let height: CGFloat = 64
        
        let label = UILabel()
        placeholderView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-30)
            make.height.lessThanOrEqualTo(height)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(offset + height)
        }
        label.textAlignment = .center
        label.numberOfLines = 3
        label.attributedText = attributedString
        
        let imageView = UIImageView(image: image)
        placeholderView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(label.snp.top)
        }
        
        var button = UIButton(type: .system )
        addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom)
            make.centerX.equalToSuperview()
        }
        button.tap { (_) in
            buttonTap?()
        }
        if let provider = buttonProvider?(button) {
            button = provider
        } else {
            button.removeFromSuperview()
        }
        
        bringSubviews?.forEach({ bringSubviewToFront($0) })
    }
    
    func hidePlaceholder() {
        guard easyPlaceholderView != nil else { return }
        self.easyPlaceholderView?.removeFromSuperview()
        self.easyPlaceholderView = nil
    }
    
}

public extension UIView {
    
    func showPlaceholder(error: Error?, image: UIImage?, tap: (() -> Void)?) {
        guard let error = error else { return }
        showPlaceholder(attributedString: error.localizedDescription.getAttributedString, image: image, backgroundColor: UIColor.white, offset: 0, bringSubviews: nil, buttonProvider: { (_) -> UIButton? in
            return nil
        }, buttonTap: nil, tap: tap)
    }
    
}

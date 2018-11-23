//
//  EasyPlaceholder.swift
//  Easy
//
//  Created by OctMon on 2018/10/12.
//

import UIKit

private var _easyPlaceholderView: Void?

public extension Easy {
    typealias Placeholder = EasyPlaceholder
}

public extension EasyGlobal {
    static var placholderEmptyImage: UIImage?
    static var placholderErrorImage: UIImage?
    
    static var placeholerImageOffset: CGFloat = 0
    static var placeholerLabelOffset: CGFloat = 0
    static var placeholerButtonOffset: CGFloat = 0
    
    static var placeholerLabelFont: UIFont = .size15
    static var placeholerLabelColor: UIColor = .hex999999
    static var placeholerLabelNumberOfLines: Int = 3
}

public struct EasyPlaceholder {
    public var style: Style
    public var title: String?
    public var image: UIImage?
    
    public init(style: Style, title: String?) {
        self.style = style
        self.title = title
    }
    
    public init(style: Style, image: UIImage?) {
        self.style = style
        self.image = image
    }
    
    public init(style: Style, title: String?, image: UIImage?) {
        self.style = style
        self.title = title
        self.image = image
    }
}

public extension EasyPlaceholder {
    
    public enum Style {
        case empty, error
    }

    static func emptyGlobal(title: String?) -> EasyPlaceholder {
        return empty(title: title, image: EasyGlobal.placholderEmptyImage)
    }
    static func emptyGlobal(image: UIImage?) -> EasyPlaceholder {
        return empty(title: EasyGlobal.errorEmpty, image: image)
    }
    static func empty(title: String?, image: UIImage?) -> EasyPlaceholder {
        return EasyPlaceholder(style: .empty, title: title, image: image)
    }

    static func errorGlobal(title: String?) -> EasyPlaceholder {
        return error(title: title, image: EasyGlobal.placholderErrorImage)
    }
    static func errorGlobal(image: UIImage?) -> EasyPlaceholder {
        return error(title: nil, image: image)
    }
    static func error(title: String?, image: UIImage?) -> EasyPlaceholder {
        return EasyPlaceholder(style: .error, title: title, image: image)
    }

}

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
        label.textAlignment = .center
        label.numberOfLines = EasyGlobal.placeholerLabelNumberOfLines
        label.textColor = EasyGlobal.placeholerLabelColor
        label.font = EasyGlobal.placeholerLabelFont
        label.attributedText = attributedString
        
        let imageView = UIImageView(image: image)
        placeholderView.addSubview(imageView)
        placeholderView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-30)
            make.height.lessThanOrEqualTo(height)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(EasyGlobal.placeholerLabelOffset + offset + height)
        }
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(label.snp.top).offset(EasyGlobal.placeholerImageOffset)
        }
        
        var button = UIButton(type: .system )
        addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).offset(EasyGlobal.placeholerButtonOffset)
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

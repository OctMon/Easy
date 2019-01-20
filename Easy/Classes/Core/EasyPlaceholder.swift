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
    static var placeholderEmptyImage: UIImage?
    static var placeholderServerImage: UIImage?
    static var placeholderNetworkImage: UIImage?
    
    static var placeholderIsUserInteractionEnabled: Bool = false
    static var placeholderBackgroundColor: UIColor = .white
    
    static var placeholderImageContentMode: UIView.ContentMode = .scaleAspectFit
    static var placeholderImageVericalMargin: CGFloat = 0
    static var placeholderImageHorizontalMargin: CGFloat? = nil
    static var placeholderLabelVerticalMargin: CGFloat = 0
    static var placeholderLabelHorizontalMargin: CGFloat = 30
    static var placeholderButtonHorizontalMargin: CGFloat = 0
    
    static var placeholderLabelFont: UIFont = .size15
    static var placeholderLabelColor: UIColor = .hex999999
    static var placeholderLabelNumberOfLines: Int = 3
}

public struct EasyPlaceholder {
    public var style: Style
    public var title: NSAttributedString?
    public var image: UIImage?
    
    public init(style: Style, title: NSAttributedString?) {
        self.style = style
        self.title = title
    }
    
    public init(style: Style, image: UIImage?) {
        self.style = style
        self.image = image
    }
    
    public init(style: Style, title: NSAttributedString?, image: UIImage?) {
        self.style = style
        self.title = title
        self.image = image
    }
}

public extension EasyPlaceholder {
    
    public enum Style {
        case empty, server, network
    }
    
    static func emptyGlobal(title: NSAttributedString?) -> EasyPlaceholder {
        return empty(title: title, image: EasyGlobal.placeholderEmptyImage)
    }
    static func emptyGlobal(image: UIImage?) -> EasyPlaceholder {
        return empty(title: EasyGlobal.errorEmpty.getAttributedString, image: image)
    }
    static func empty(title: NSAttributedString?, image: UIImage?) -> EasyPlaceholder {
        return EasyPlaceholder(style: .empty, title: title, image: image)
    }
    
    static func serverGlobal(title: NSAttributedString?) -> EasyPlaceholder {
        return server(title: title, image: EasyGlobal.placeholderServerImage)
    }
    static func serverGlobal(image: UIImage?) -> EasyPlaceholder {
        return server(title: nil, image: image)
    }
    static func server(title: NSAttributedString?, image: UIImage?) -> EasyPlaceholder {
        return EasyPlaceholder(style: .server, title: title, image: image)
    }
    
    static func networkGlobal(title: NSAttributedString?) -> EasyPlaceholder {
        return network(title: title, image: EasyGlobal.placeholderNetworkImage)
    }
    static func networkGlobal(image: UIImage?) -> EasyPlaceholder {
        return network(title: nil, image: image)
    }
    static func network(title: NSAttributedString?, image: UIImage?) -> EasyPlaceholder {
        return EasyPlaceholder(style: .network, title: title, image: image)
    }
    
}

public extension UIView {
    
    private var easyPlaceholderView: UIView? {
        get { return objc_getAssociatedObject(self, &_easyPlaceholderView) as? UIView }
        set { objc_setAssociatedObject(self, &_easyPlaceholderView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func showPlaceholder(attributedString: NSAttributedString?, image: UIImage? = nil, backgroundColor: UIColor = EasyGlobal.placeholderBackgroundColor, offset: CGFloat = 0, isUserInteractionEnabled: Bool = EasyGlobal.placeholderIsUserInteractionEnabled, bringSubviews: [UIView]? = nil, buttonProvider: ((UIButton) -> UIButton?)? = nil, buttonTap: (() -> Void)? = nil, tap: (() -> Void)? = nil) {
        if easyPlaceholderView != nil {
            hidePlaceholder()
        }
        easyPlaceholderView = UIView()
        guard let placeholderView = easyPlaceholderView else { return }
        addSubview(placeholderView)
        placeholderView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        placeholderView.tap { (_) in
            tap?()
        }
        placeholderView.isUserInteractionEnabled = isUserInteractionEnabled
        placeholderView.backgroundColor = backgroundColor
        
        let height: CGFloat = 64
        
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = EasyGlobal.placeholderLabelNumberOfLines
        label.textColor = EasyGlobal.placeholderLabelColor
        label.font = EasyGlobal.placeholderLabelFont
        label.attributedText = attributedString
        
        let imageView = UIImageView(image: image).then {
            $0.contentMode = EasyGlobal.placeholderImageContentMode
        }
        placeholderView.addSubview(imageView)
        placeholderView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-EasyGlobal.placeholderLabelHorizontalMargin * 2)
            make.height.lessThanOrEqualTo(height)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(EasyGlobal.placeholderLabelVerticalMargin + offset + height)
        }
        imageView.snp.makeConstraints { (make) in
            if let placeholderImageHorizontalMargin = EasyGlobal.placeholderImageHorizontalMargin {
                make.width.lessThanOrEqualToSuperview().offset(-placeholderImageHorizontalMargin * 2)
            }
            make.centerX.equalToSuperview()
            make.bottom.equalTo(label.snp.top).offset(EasyGlobal.placeholderImageVericalMargin)
        }
        
        var button = UIButton(type: .system )
        addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).offset(EasyGlobal.placeholderButtonHorizontalMargin)
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
        showPlaceholder(attributedString: error.localizedDescription.getAttributedString, image: image, tap: tap)
    }
    
}

//
//  EasyPopupView.swift
//  Easy
//
//  Created by OctMon on 2018/10/13.
//

import UIKit

public extension Easy {
    typealias PopupView = EasyPopupView
}

public class EasyPopupView: UIView {

    private var view: UIView?
    private var viewController: UIViewController?
    private var dismissHandler: (() -> Void)?
    
    public var animationDuration: TimeInterval = 0.25
    public var dismissOnBlackOverlayTap = true
    public var blackOverlayColor = UIColor(white: 0, alpha: 0.4)
    
    deinit {
        EasyLog.debug(toDeinit)
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

public extension EasyPopupView {
    
    convenience init(_ view: UIView) {
        self.init(frame: EasyApp.screenBounds)
        self.view = view
        if let view = self.view {
            addSubview(view)
        }
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.addTarget(self, action: #selector(dismiss))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    convenience init(_ viewController: UIViewController, height: CGFloat) {
        self.init(viewController.view)
        view?.height = height
        self.viewController = viewController
    }
    
    func showWithBottom(showHandler: (() -> Void)? = nil, dismissHandler: (() -> Void)? = nil) {
        show(originY: EasyApp.screenHeight - (self.view?.frame.height ?? 0), showHandler: showHandler, dismissHandler: dismissHandler)
    }
    
    func showWithCenter(showHandler: (() -> Void)? = nil, dismissHandler: (() -> Void)? = nil) {
        show(originY: (EasyApp.screenHeight - (self.view?.frame.height ?? 0)) * 0.5, showHandler: showHandler, dismissHandler: dismissHandler)
    }
    
    func show(originY: CGFloat, showHandler: (() -> Void)? = nil, dismissHandler: (() -> Void)? = nil) {
        self.dismissHandler = dismissHandler
        EasyApp.window?.addSubview(self)
        self.backgroundColor = UIColor.clear
        
        if animationDuration == 0 {
            self.view?.y = originY
            self.view?.alpha = 0
            UIView.animate(withDuration: 0.25) { [weak self] in
                guard let `self` = self else { return }
                self.backgroundColor = self.blackOverlayColor
                self.view?.alpha = 1
                showHandler?()
            }
        } else {
            view?.y = EasyApp.screenHeight
            UIView.animate(withDuration: animationDuration) { [weak self] in
                guard let `self` = self else { return }
                self.backgroundColor = self.blackOverlayColor
                self.view?.y = originY
                showHandler?()
            }
        }
    }
    
    @objc func dismiss() {
        if animationDuration == 0 {
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                guard let `self` = self else { return }
                self.backgroundColor = UIColor.clear
                self.view?.alpha = 0
            }) { [weak self] (completion) in
                if completion {
                    guard let `self` = self else { return }
                    self.dismissHandler?()
                    self.subviews.forEach({ $0.removeFromSuperview() })
                    self.removeFromSuperview()
                    self.viewController = nil
                    self.view = nil
                }

            }
        } else {
            UIView.animate(withDuration: animationDuration, animations: { [weak self] in
                guard let `self` = self else { return }
                self.backgroundColor = UIColor.clear
                self.view?.frame.origin.y = EasyApp.screenHeight
            }) { [weak self] (completion) in
                if completion {
                    guard let `self` = self else { return }
                    self.dismissHandler?()
                    self.subviews.forEach({ $0.removeFromSuperview() })
                    self.removeFromSuperview()
                    self.viewController = nil
                    self.view = nil
                }
            }
        }
    }
    
}

extension EasyPopupView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if !dismissOnBlackOverlayTap {
            return false
        }
        if let view = touch.view, let popupView = self.view, view.isDescendant(of: popupView) {
            return false
        }
        return true
    }
    
}

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
    
    private var transition = Transition.bottom
    
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
    
    enum Transition {
        case fade
        case top
        case bottom
        case none
    }
    
    convenience init(_ view: UIView, transition: Transition) {
        self.init(frame: EasyApp.screenBounds)
        self.transition = transition
        self.view = view
        if let view = self.view {
            addSubview(view)
        }
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.addTarget(self, action: #selector(dismiss))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    convenience init(_ viewController: UIViewController, height: CGFloat, transition: Transition) {
        self.init(viewController.view, transition: transition)
        view?.height = height
        self.viewController = viewController
    }
    
    func showWithTop(showHandler: (() -> Void)? = nil, dismissHandler: (() -> Void)? = nil) {
        show(originY: 0, showHandler: showHandler, dismissHandler: dismissHandler)
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
        self.backgroundColor = .clear
        
        switch transition {
        case .fade:
            view?.y = originY
            view?.alpha = 0
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.view?.alpha = 1
                self?.showAnimation(showHandler)
            }
        case .top:
            view?.y = -EasyApp.screenHeight
            UIView.animate(withDuration: animationDuration) { [weak self] in
                self?.view?.y = originY
                self?.showAnimation(showHandler)
            }
        case .bottom:
            view?.y = EasyApp.screenHeight
            UIView.animate(withDuration: animationDuration) { [weak self] in
                self?.view?.y = originY
                self?.showAnimation(showHandler)
            }
        case .none:
            showAnimation(showHandler)
        }
    }
    
    @objc func dismiss() {
        switch transition {
        case .fade:
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.backgroundColor = .clear
                self?.view?.alpha = 0
            }) { [weak self] (completion) in
                if completion {
                    self?.dismissAnimation(self?.dismissHandler)
                }
            }
        case .top:
            UIView.animate(withDuration: animationDuration, animations: { [weak self] in
                self?.backgroundColor = .clear
                self?.view?.frame.origin.y = -EasyApp.screenHeight
            }) { [weak self] (completion) in
                if completion {
                    self?.dismissAnimation(self?.dismissHandler)
                }
            }
        case .bottom:
            UIView.animate(withDuration: animationDuration, animations: { [weak self] in
                self?.backgroundColor = .clear
                self?.view?.frame.origin.y = EasyApp.screenHeight
            }) { [weak self] (completion) in
                if completion {
                    self?.dismissAnimation(self?.dismissHandler)
                }
            }
        case .none:
            dismissAnimation(dismissHandler)
        }
    }
    
    private func showAnimation(_ handler: (() -> Void)?) {
        backgroundColor = self.blackOverlayColor
        handler?()
    }
    
    private func dismissAnimation(_ handler: (() -> Void)?) {
        removeFromSuperview()
        handler?()
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

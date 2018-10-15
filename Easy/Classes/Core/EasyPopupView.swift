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
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

public extension EasyPopupView {
    
    convenience init(_ view: UIView, frame: CGRect? = nil) {
        self.init(frame: EasyApp.screenBounds)
        
        if let frame = frame {
            view.frame = frame
        }
        self.view = view
        if let view = self.view {
            addSubview(view)
        }
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.addTarget(self, action: #selector(dismiss))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    convenience init(edgeView view: UIView, height: CGFloat) {
        self.init(view, frame: CGRect(x: 0, y: 0, width: EasyApp.screenWidth, height: EasyApp.screenHeight - height))
    }
    
    convenience init(edgeViewController viewController: UIViewController, height: CGFloat) {
        self.init(viewController, frame: CGRect(x: 0, y: 0, width: EasyApp.screenWidth, height: EasyApp.screenHeight - height))
    }
    
    convenience init(_ viewController: UIViewController, frame: CGRect? = nil) {
        self.init(viewController.view, frame: frame)
        self.viewController = viewController
    }
    
    func show(showHandler: (() -> Void)? = nil, dismissHandler: (() -> Void)? = nil) {
        self.dismissHandler = dismissHandler
        
        EasyApp.window?.addSubview(self)
        self.backgroundColor = UIColor.clear
        view?.frame.origin.y = EasyApp.screenHeight
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let `self` = self else { return }
            self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.view?.frame.origin.y = EasyApp.screenHeight - (self.view?.frame.height ?? 0)
            showHandler?()
        }
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
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
            }
        }
    }
    
}

extension EasyPopupView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, let popupView = self.view, view.isDescendant(of: popupView) {
            return false
        }
        return true
    }
    
}

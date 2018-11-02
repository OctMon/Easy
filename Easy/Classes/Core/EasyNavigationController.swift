//
//  EasyNavigationController.swift
//  Easy
//
//  Created by OctMon on 2018/10/12.
//

import UIKit

#if canImport(RTRootNavigationController)
import RTRootNavigationController

public extension Easy {
    typealias NavigationController = EasyNavigationController
}

public class EasyNavigationController: RTRootNavigationController {
    
    deinit { EasyLog.debug(toDeinit) }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        useSystemBackBarButtonItem = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        useSystemBackBarButtonItem = true
    }
    
}
#endif

/// 拦截返回按钮
private protocol EasyNavigationShouldPopOnBackButton {
    func navigationShouldPopOnBackButton() -> Bool
    func navigationPopOnBackHandler() -> Void
}

extension UIViewController: EasyNavigationShouldPopOnBackButton {
    /// 拦截返回按钮, 返回false无法返回
    @objc open func navigationShouldPopOnBackButton() -> Bool {
        return true
    }
    /// 拦截返回事件, 可自定义点击 返回按钮后的事件
    @objc open func navigationPopOnBackHandler() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension UINavigationController: UINavigationBarDelegate {
    
    open func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if let items = navigationBar.items, viewControllers.count < items.count { return true }
        var shouldPop = true
        let vc = topViewController
        if let topVC = vc, topVC.responds(to: #selector(navigationShouldPopOnBackButton)) {
            shouldPop = topVC.navigationShouldPopOnBackButton()
        }
        if shouldPop {
            if let topVC = vc, topVC.responds(to: #selector(navigationPopOnBackHandler)) {
                EasyApp.runInMain {
                    topVC.navigationPopOnBackHandler()
                }
            } else {
                EasyApp.runInMain {
                    self.popViewController(animated: true)
                }
            }
        } else {
            for subview in navigationBar.subviews {
                if subview.alpha > 0.0 && subview.alpha < 1.0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        subview.alpha = 1.0
                    })
                }
            }
        }
        return false
    }
    
}

class EasyFullScreenPopGesture: NSObject {
    
    static func open() -> Void {
        UIViewController.vcFullScreenInit()
        UINavigationController.navFullScreenInit()
    }
    
}

private class _FullScreenPopGestureDelegate: NSObject, UIGestureRecognizerDelegate {
    
    weak var navigationController: UINavigationController?
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navController = self.navigationController else { return false }
        // 忽略没有控制器可以 push 的时候
        guard navController.viewControllers.count > 1 else {
            return false
        }
        // 控制器不允许交互弹出时忽略
        guard let topViewController = navController.viewControllers.last, !topViewController.interactivePopDisabled else {
            return false
        }
        
        if let isTransitioning = navController.value(forKey: "_isTransitioning") as? Bool, isTransitioning {
            return false
        }
        
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        
        // 始位置超出最大允许初始距离时忽略
        let beginningLocation = panGesture.location(in: gestureRecognizer.view)
        let maxAllowedInitialDistance = topViewController.interactivePopMaxAllowedInitialDistanceToLeftEdge
        if maxAllowedInitialDistance > 0, beginningLocation.x > maxAllowedInitialDistance { return false }
        
        let translation = panGesture.translation(in: gestureRecognizer.view)
        let isLeftToRight = UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.leftToRight
        let multiplier: CGFloat = isLeftToRight ? 1 : -1
        if (translation.x * multiplier) <= 0 {
            return false
        }
        return true
    }
    
}

extension UIViewController {
    
    fileprivate static func vcFullScreenInit() {
        let appear_originalMethod = class_getInstanceMethod(self, #selector(viewWillAppear(_:)))
        let appear_swizzledMethod = class_getInstanceMethod(self, #selector(_viewWillAppear))
        method_exchangeImplementations(appear_originalMethod!, appear_swizzledMethod!)
        
        let disappear_originalMethod = class_getInstanceMethod(self, #selector(viewWillDisappear(_:)))
        let disappear_swizzledMethod = class_getInstanceMethod(self, #selector(_viewWillDisappear))
        method_exchangeImplementations(disappear_originalMethod!, disappear_swizzledMethod!)
    }
    
    private struct Key {
        static var interactivePopDisabled: Void?
        static var maxAllowedInitialDistance: Void?
        static var prefersNavigationBarHidden: Void?
        static var willAppearInjectHandler: Void?
    }
    
    fileprivate var interactivePopDisabled: Bool {
        get { return (objc_getAssociatedObject(self, &Key.interactivePopDisabled) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &Key.interactivePopDisabled, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    fileprivate var interactivePopMaxAllowedInitialDistanceToLeftEdge: CGFloat {
        get { return (objc_getAssociatedObject(self, &Key.maxAllowedInitialDistance) as? CGFloat) ?? 0.00 }
        set { objc_setAssociatedObject(self, &Key.maxAllowedInitialDistance, max(0, newValue), .OBJC_ASSOCIATION_COPY) }
    }
    
    fileprivate var prefersNavigationBarHidden: Bool {
        get {
            guard let bools = objc_getAssociatedObject(self, &Key.prefersNavigationBarHidden) as? Bool  else { return false }
            return bools
        }
        set {
            objc_setAssociatedObject(self, &Key.prefersNavigationBarHidden, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    fileprivate var willAppearInjectHandler: ViewControllerWillAppearInjectHandler? {
        get { return objc_getAssociatedObject(self, &Key.willAppearInjectHandler) as? ViewControllerWillAppearInjectHandler }
        set { objc_setAssociatedObject(self, &Key.willAppearInjectHandler, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    @objc fileprivate func _viewWillAppear(_ animated: Bool) {
        self._viewWillAppear(animated)
        
        self.willAppearInjectHandler?(self, animated)
    }
    
    @objc fileprivate func _viewWillDisappear(animated: Bool) {
        self._viewWillDisappear(animated: animated)
        
        let vc = self.navigationController?.viewControllers.last
        
        if vc != nil, vc!.prefersNavigationBarHidden, !self.prefersNavigationBarHidden {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
}

private typealias ViewControllerWillAppearInjectHandler = (_ viewController: UIViewController, _ animated: Bool) -> Void

extension UINavigationController {
    
    fileprivate static func navFullScreenInit() {
        let originalSelector = #selector(pushViewController(_:animated:))
        let swizzledSelector = #selector(_pushViewController)
        
        guard let originalMethod = class_getInstanceMethod(self, originalSelector) else { return }
        guard let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else { return }
        
        let success = class_addMethod(self.classForCoder(), originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        if success {
            class_replaceMethod(self.classForCoder(), swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    private struct Key {
        static var cmd: Void?
        static var popGestureRecognizerDelegate: Void?
        static var fullscreenPopGestureRecognizer: Void?
        static var viewControllerBasedNavigationBarAppearanceEnabled: Void?
    }
    
    @objc private func _pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.interactivePopGestureRecognizer?.view?.gestureRecognizers?.contains(self.fullscreenPopGestureRecognizer) == false {
            self.interactivePopGestureRecognizer?.view?.addGestureRecognizer(self.fullscreenPopGestureRecognizer)
            
            guard let internalTargets = self.interactivePopGestureRecognizer?.value(forKey: "targets") as? [NSObject] else { return }
            guard let internalTarget = internalTargets.first!.value(forKey: "target") else { return } // internalTargets?.first?.value(forKey: "target") else { return }
            let internalAction = NSSelectorFromString("handleNavigationTransition:")
            self.fullscreenPopGestureRecognizer.delegate = self.popGestureRecognizerDelegate
            self.fullscreenPopGestureRecognizer.addTarget(internalTarget, action: internalAction)
            
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        self.setupViewControllerBasedNavigationBarAppearanceIfNeeded(viewController)
        
        if !self.viewControllers.contains(viewController) {
            self._pushViewController(viewController, animated: animated)
        }
    }
    
    private func setupViewControllerBasedNavigationBarAppearanceIfNeeded(_ appearingViewController: UIViewController) -> Void {
        guard self.viewControllerBasedNavigationBarAppearanceEnabled else {
            return
        }
        let Handler: ViewControllerWillAppearInjectHandler = { [weak self] (vc, animated) in
            self.unwrapped({ $0.setNavigationBarHidden(vc.prefersNavigationBarHidden, animated: animated) })
        }
        appearingViewController.willAppearInjectHandler = Handler
        if let disappearingViewController = self.viewControllers.last, disappearingViewController.willAppearInjectHandler.isNone {
            disappearingViewController.willAppearInjectHandler = Handler
        }
    }
    
    
    private var fullscreenPopGestureRecognizer: UIPanGestureRecognizer {
        guard let pan = objc_getAssociatedObject(self, &Key.fullscreenPopGestureRecognizer) as? UIPanGestureRecognizer else {
            let gesture = UIPanGestureRecognizer()
            gesture.maximumNumberOfTouches = 1
            objc_setAssociatedObject(self, &Key.fullscreenPopGestureRecognizer, gesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return gesture
        }
        return pan
    }
    
    private var popGestureRecognizerDelegate: _FullScreenPopGestureDelegate {
        guard let delegate = objc_getAssociatedObject(self, &Key.popGestureRecognizerDelegate) as? _FullScreenPopGestureDelegate else {
            let delegate = _FullScreenPopGestureDelegate()
            delegate.navigationController = self
            objc_setAssociatedObject(self, &Key.popGestureRecognizerDelegate, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return delegate
        }
        return delegate
    }
    
    private var viewControllerBasedNavigationBarAppearanceEnabled: Bool {
        get {
            guard let enabel = objc_getAssociatedObject(self, &Key.viewControllerBasedNavigationBarAppearanceEnabled) as? Bool else {
                self.viewControllerBasedNavigationBarAppearanceEnabled = true
                return true
            }
            return enabel
        }
        set {
            objc_setAssociatedObject(self, &Key.viewControllerBasedNavigationBarAppearanceEnabled, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

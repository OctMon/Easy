//
//  EasyPage.swift
//  Easy
//
//  Created by OctMon on 2018/10/30.
//

import UIKit
import WMPageController

public extension Easy {
    typealias Page = EasyPage
}

open class EasyPage: WMPageController {
    
    deinit { EasyLog.debug(toDeinit) }
    
    private lazy var viewControllerHandler: ((Int) -> UIViewController)? = { return nil }()
    
    public var menuViewFrame = CGRect(x: 0, y: 0, width: .screenWidth, height: 44)
    public var contentViewFrame: CGRect?
    public var menuItemTitleSize: CGFloat = 14
    public var menuItemTtleColorForNormal = UIColor.hex333333
    public var menuItemTtleColorForSelected = EasyGlobal.tint
    
    public var menuViewBottomSpace: CGFloat = 0 {
        willSet {
            lineView.snp.remakeConstraints { (make) in
                make.top.equalTo(menuViewFrame.maxY)
                make.left.right.equalToSuperview()
                make.height.equalTo(newValue)
            }
        }
    }
    public var menuViewBottomColor: UIColor = EasyGlobal.tableViewBackgroundColor {
        willSet {
            lineView.backgroundColor = newValue
        }
    }
    
    private let lineView = UIView()
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = EasyGlobal.background
        setBackBarButtonItem(title: EasyGlobal.backBarButtonItemTitle)
        
        EasyGlobal.navigationBarTintColor.unwrapped { (color) in
            navigationBar?.setTintColor(color)
        }
        navigationBar?.setBackgroundImage(EasyGlobal.navigationBarBackgroundImage, for: .default)
        navigationBar?.titleTextAttributes = EasyGlobal.navigationBarTitleTextAttributes
        if EasyGlobal.navigationBarIsShadowNull {
            navigationBar?.setShadowNull()
        }
        
        setBackIndicator(EasyGlobal.backBarButtonItemImage)
        
        menuViewStyle = .line
        progressColor = EasyGlobal.tint
        
        view.addSubview(lineView)
        
        configure()
    }
    
    open func configure() { }
    
    open func request() { }
    
}

public extension EasyPage {
    
    func setPage(menuViewStyle: WMMenuViewStyle = .line, titles: [String], viewControllerHandler: @escaping (Int) -> UIViewController) {
        self.menuViewStyle = menuViewStyle
        self.titles = titles
        self.viewControllerHandler = viewControllerHandler
        reloadData()
    }
    
}

extension EasyPage {
    
    open override func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return titles?.count ?? 0
    }
    
    open override func pageController(_ pageController: WMPageController, preferredFrameFor menuView: WMMenuView) -> CGRect {
        return menuViewFrame
    }
    
    open override func pageController(_ pageController: WMPageController, preferredFrameForContentView contentView: WMScrollView) -> CGRect {
        if let contentViewFrame = contentViewFrame {
            return contentViewFrame
        }
        return CGRect(x: 0, y: menuViewFrame.origin.y + menuViewFrame.height, width: .screenWidth, height: .screenHeight - navigationBottom - menuViewFrame.origin.y - menuViewFrame.height)
    }
    
    open override func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        return viewControllerHandler?(index) ?? EasyViewController()
    }
    
    open override func menuView(_ menu: WMMenuView!, titleSizeFor state: WMMenuItemState, at index: Int) -> CGFloat {
        return menuItemTitleSize
    }
    
    open override func menuView(_ menu: WMMenuView!, titleColorFor state: WMMenuItemState, at index: Int) -> UIColor! {
        switch state {
        case .normal:
            return menuItemTtleColorForNormal
        case .selected:
            return menuItemTtleColorForSelected
        }
    }
    
}

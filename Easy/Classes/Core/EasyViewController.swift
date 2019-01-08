//
//  EasyViewController.swift
//  Easy
//
//  Created by OctMon on 2018/10/11.
//

import UIKit

public extension Easy {
    typealias ViewController = EasyViewController
}

open class EasyViewController: UIViewController {
    
    deinit { EasyLog.debug(toDeinit) }
    
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
        
        configure()
    }
    
    open func configure() { }
    
    open func request() { }

}

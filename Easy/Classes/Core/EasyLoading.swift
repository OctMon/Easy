//
//  EasyLoading.swift
//  Easy
//
//  Created by OctMon on 2018/10/12.
//

import UIKit

#if canImport(MBProgressHUD)
import MBProgressHUD
#endif

public extension UIView {
    
    func showLoading(_ text: String? = EasyGlobal.loadingText) {
        #if canImport(MBProgressHUD)
        endEditing(true)
        show(mode: .indeterminate, text: text)
        #endif
    }
    
    func hideLoading() {
        #if canImport(MBProgressHUD)
        MBProgressHUD.hide(for: self, animated: true)
        #endif
    }
    
    func showText(_ text: String?, afterDelay: TimeInterval = 1) {
        #if canImport(MBProgressHUD)
        guard let text = text, !text.isEmpty else { return }
        show(mode: .text, text: text, afterDelay: afterDelay)
        #endif
    }
    
    #if canImport(MBProgressHUD)
    func show(mode: MBProgressHUDMode, text: String?, afterDelay: TimeInterval = 1) {
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.animationType = .fade
        hud.mode = mode
        hud.label.numberOfLines = 0
        hud.label.text = text
        hud.removeFromSuperViewOnHide = true
        if mode == .text {
            hud.hide(animated: true, afterDelay: afterDelay)
        }
    }
    #endif
    
}

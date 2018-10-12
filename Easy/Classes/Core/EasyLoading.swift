//
//  EasyLoading.swift
//  Easy
//
//  Created by OctMon on 2018/10/12.
//

import UIKit

#if canImport(MBProgressHUD)
import MBProgressHUD

public extension UIView {
    
    func showLoading(_ text: String? = nil) {
        endEditing(true)
        show(mode: .indeterminate, text: text)
    }
    
    func hideLoading() {
        MBProgressHUD.hide(for: self, animated: true)
    }
    
    func showText(_ text: String?, afterDelay: TimeInterval = 1) {
        guard let text = text, !text.isEmpty else { return }
        show(mode: .text, text: text, afterDelay: afterDelay)
    }
    
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
    
}
#endif

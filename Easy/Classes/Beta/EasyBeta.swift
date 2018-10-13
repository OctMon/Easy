//
//  EasyBeta.swift
//  Easy
//
//  Created by OctMon on 2018/10/13.
//

import UIKit
import FLEX

public struct EasyBeta {
    
}

public extension EasyBeta {
    
    static func configTest() {
        FLEXManager.shared().isNetworkDebuggingEnabled = true
        EasyLog.clear()
        EasyApp.window?.longPress(numberOfTapsRequired: 3, numberOfTouchesRequired: 1, handler: { (r) in
            if r.state == .began {
                isShowTestTool.toggle()
            }
        }).delegate = BetaGesture.shared
    }
    
}

extension EasySession {
    
    func addToShowBaseURL() {
        guard self.config.url.global == nil else {
            EasyLog.debug("info: addToShowBaseURL && (global == nil)")
            return
        }
        sessions.append(self)
    }
    
}

var sessions = [EasySession]()
var isShowTestTool = false {
    didSet {
        if isShowTestTool {
            (EasyApp.currentViewController ?? EasyApp.currentTabBarController)?.showDetailViewController(UINavigationController(rootViewController: EasyTestViewController()), sender: nil)
        } else {
            EasyApp.currentViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

private class BetaGesture: NSObject, UIGestureRecognizerDelegate {
    
    static var shared = BetaGesture()
    
    private override init () { }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

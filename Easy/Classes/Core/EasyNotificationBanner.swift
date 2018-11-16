//
//  EasyNotificationBanner.swift
//  Easy
//
//  Created by OctMon on 2018/11/15.
//

import UIKit

extension Easy {
    typealias NotificationBanner = EasyNotificationBanner
}

private var bannerTop: CGFloat = .screenHeight - 44 - EasyApp.safeBottomEdge
private var bannerWidth: CGFloat = .screenWidth * 0.8
private var bannerStart: CGFloat = .screenWidth * 2

public class EasyNotificationBanner: NSObject {
    
    deinit {
        EasyLog.debug(toDeinit)
    }
    
    private let label = UILabel(frame: CGRect(x: 0, y: bannerTop, width: bannerWidth, height: 44)).then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.adjustsFontSizeToFitWidth = true
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.textColor = EasyGlobal.tint
        $0.backgroundColor = UIColor(white: 0, alpha: 0.4)
        $0.setCornerRadius(5)
    }
    
    public func show(text: String?, afterDelay: TimeInterval = 1.5, tap: (() -> Void)? = nil) {
        guard let text = text else { return }
        EasyApp.window?.addSubview(label)
        label.text = text
        label.layer.position = CGPoint(x: bannerStart, y: bannerTop)
        label.tap { (_) in
            tap?()
        }
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: [.allowUserInteraction, .curveEaseIn], animations: {
            self.label.layer.position = CGPoint(x: bannerWidth * 0.6, y: bannerTop)
        }, completion: { (_) in
            EasyApp.runInMain(delay: afterDelay, handler: {
                self.hide()
            })
        })
    }
    
    public func hide() {
        let startPoint = label.center
        label.layer.position = startPoint
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: [.allowUserInteraction, .curveEaseIn], animations: {
            self.label.layer.position = CGPoint(x: bannerStart, y: bannerTop)
        }, completion: { (_) in
            self.label.removeFromSuperview()
        })
    }
    
}

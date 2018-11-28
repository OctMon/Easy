//
//  EasyLaunchView.swift
//  Easy
//
//  Created by OctMon on 2018/10/14.
//

import UIKit

public extension EasyApp {
    
    static func showLaunch(duration: TimeInterval, imageURL: String?, didHideHandler: (() -> Void)?) {
        let launch = EasyLaunchView(imageURL: imageURL, didHideHandler: didHideHandler)
        EasyApp.runInMain(delay: duration) {
            didHideHandler?()
            launch.hide()
        }
    }
    
    static func showLaunch(duration: TimeInterval, image: UIImage?, didHideHandler: (() -> Void)?) {
        let launch = EasyLaunchView(image: image, didHideHandler: didHideHandler)
        EasyApp.runInMain(delay: duration) {
            didHideHandler?()
            launch.hide()
        }
    }
    
}

class EasyLaunchView: UIView {
    
    private let imageView = UIImageView(image: UIImage.launchImage)
    
    private var imageURL: String?
    
    deinit {
        EasyApp.notificationCenter.removeObserver(self)
    }
    
    init(image: UIImage?, didHideHandler: (() -> Void)?) {
        super.init(frame: EasyApp.screenBounds)
        
        config(image: image, imageURL: nil, didHideHandler: didHideHandler)
    }
    
    init(imageURL: String?, didHideHandler: (() -> Void)?) {
        super.init(frame: EasyApp.screenBounds)
        
        config(image: nil, imageURL: imageURL, didHideHandler: didHideHandler)
    }
    
    private func config(image: UIImage?, imageURL: String?, didHideHandler: (() -> Void)?) {
        addSubview(imageView)
        
        EasyApp.notificationCenter.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: nil) { [weak self] (_) in
            EasyApp.runInMain(handler: {
                guard let self = self else { return }
                EasyApp.window?.addSubview(self)
                if let image = image {
                    self.imageView.image = image
                } else if let url = imageURL, !url.isEmpty {
                    #if canImport(SDWebImage) || canImport(KingfisherWebP)
                    self.imageView.setImage(url: url, placeholderImage: self.imageView.image)
                    #endif
                }
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hide(withDuration: TimeInterval = 0.5) {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
}

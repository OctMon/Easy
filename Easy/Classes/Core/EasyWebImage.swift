//
//  EasyWebImage.swift
//  Easy
//
//  Created by OctMon on 2018/10/12.
//

import UIKit

#if canImport(SDWebImage)
import SDWebImage

public extension Easy {
    typealias WebImage = EasyWebImage
}

public struct EasyWebImage {
    public static var isPrintWebImageUrl = false
}

public extension UIImageView {
    
    func setFadeImage(url: String, placeholderImage: UIImage?) {
        setImage(url: url, placeholderImage: placeholderImage, options: [], progress: nil) { [weak self] (image, error, cacheType, imageURL) in
            if image != nil, cacheType != .memory {
                let animation = CATransition()
                animation.duration = 0.25
                animation.type = CATransitionType.fade
                animation.isRemovedOnCompletion = true
                self?.layer.add(animation, forKey: "easySetFadeImage")
            }
            self?.layer.removeAnimation(forKey: "easySetFadeImage")
        }
    }
    
    func setImage(url: String, placeholderImage: UIImage?) {
        setImage(url: url, placeholderImage: placeholderImage, options: [], progress: nil, completed: nil)
    }
    
    func setImage(url: String, placeholderImage: UIImage?, options: SDWebImageOptions, progress: SDWebImageDownloaderProgressBlock?, completed: SDExternalCompletionBlock?) {
        if EasyWebImage.isPrintWebImageUrl {
            EasyLog.debug(url)
        }
        let url = URL(string: url) ?? URL(string: "https")
        sd_setImage(with: url, placeholderImage: placeholderImage, options: options, progress: progress, completed: completed)
    }
    
    func setWebPImage(_ name: String) {
        let webP = ".webp"
        var url = name
        if !url.hasSuffix(webP) {
            url += webP
        }
        guard let path = Bundle.main.path(forResource: url, ofType: nil) else { return }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return }
        image = UIImage.sd_image(with: data)
    }
    
}

public extension EasyApp {
    
    func calculateDiskCacheSize(_ completionHandler: @escaping ((UInt, String) -> Void)) {
        SDImageCache.shared.calculateSize(completionBlock: { (fileCount, cacheSize) in
            completionHandler(cacheSize, "\(cacheSize / 1024 / 1024)"+"M")
        })
    }
    
    func clearWebImageMemoryCache() {
        SDImageCache.shared.clearMemory()
    }
    
    func clearWebImageDiskCache(onCompletion: (() -> Void)? = nil) {
        SDImageCache.shared.clearDisk(onCompletion: {
            onCompletion?()
        })
    }
    
    func clearWebImageAllCache() {
        clearWebImageMemoryCache()
        clearWebImageDiskCache()
    }

}

#elseif canImport(Kingfisher)
import Kingfisher

public extension UIImageView {
    
    func setFadeImage(url: String, placeholderImage: UIImage?) {
        setImage(url: url, placeholder: placeholderImage)
    }
    
    func setImage(url: String, placeholderImage: UIImage?) {
        setImage(url: url, placeholder: placeholderImage, optionsInfo: [])
    }
    
    func setImage(url: String, placeholder: Image? = nil, optionsInfo: KingfisherOptionsInfo? = [.transition(.fade(0.3))], progressBlock: DownloadProgressBlock? = nil, completionHandler: CompletionHandler? = nil) {
        if EasyWebImage.isPrintWebImageUrl {
            EasyLog.debug(url)
        }
        kf.setImage(with: URL(string: url), placeholder: placeholder, options: optionsInfo, progressBlock: progressBlock, completionHandler: completionHandler)
    }
    
}

public extension EasyApp {
    
    func calculateDiskCacheSize(_ completionHandler: @escaping ((UInt, String) -> Void)) {
        KingfisherManager.shared.cache.calculateDiskCacheSize { (cacheSize) in
            completionHandler(cacheSize, "\(cacheSize / 1024 / 1024)"+"M")
        }
    }
    
    func clearWebImageMemoryCache() {
        KingfisherManager.shared.cache.clearMemoryCache()
    }
    
    func clearWebImageDiskCache(onCompletion: (() -> Void)? = nil) {
        KingfisherManager.shared.cache.clearDiskCache(completion: onCompletion)
    }
    
    func clearWebImageAllCache() {
        clearWebImageMemoryCache()
        clearWebImageDiskCache()
    }

}

#endif

#if canImport(KingfisherWebP)
import KingfisherWebP

public extension UIImageView {
    
    func setWebPImage(_ name: String) {
        let webP = ".webp"
        var url = name
        if !url.hasSuffix(webP) {
            url += webP
        }
        guard let path = Bundle.main.path(forResource: url, ofType: nil) else { return }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return }
        image = WebPSerializer.default.image(with: data, options: nil)
    }
    
}
#endif

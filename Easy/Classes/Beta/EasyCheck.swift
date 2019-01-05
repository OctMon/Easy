//
//  EasyCheck.swift
//  Easy
//
//  Created by OctMon on 2018/10/13.
//

import UIKit

public struct EasyCheck {
    
    private static var isShow: Bool = false
    private static let ignoreBuildKey = "easyIgnoreBuildKey".md5
    
    private static let session: EasySession = {
        var config = EasyConfig()
        config.url.global = "http://www.pgyer.com"
        return EasySession(config)
    }()
    
    private init() {}
    
    static func requestPgyerBeta(api_key: String, shortcutUrl: String, headerImage: UIImage?) {
        guard !isShow else { return }
        session.post(path: "apiv2/app/getByShortcut", isURLEncoding: true, parameters: ["_api_key": api_key, "buildShortcutUrl": shortcutUrl]) { (dataResponse) in
            guard dataResponse.valid else {
                EasyLog.debug(dataResponse.error)
                return
            }
            
            let buildVersionNo = dataResponse.dataParameters["buildVersionNo"].toIntValue
            let buildBundle = EasyApp.bundleBuild.toIntValue
            guard buildVersionNo > buildBundle else { return }
            let ignoreBuild = UserDefaults.standard.integer(forKey: ignoreBuildKey)
            guard buildBundle != ignoreBuild else { return }
            
            var buttonTitles = ["立即升级".getAttributedString(font: .size15, foregroundColor: UIColor.white)]
            var buttonBackgroundImages = [EasyGlobal.tint.toImage]
            buttonTitles.insert("以后再说".getAttributedString(font: .size15, foregroundColor: .hex666666), at: 0)
            buttonBackgroundImages.insert(UIColor.white.toImage, at: 0)
            EasyApp.showUpdateAlert(image: headerImage, title: "发现新版本beta".getAttributedString(font: .size21, foregroundColor: .hex333333).append(title: "  v\(buildVersionNo)", font: .size12, foregroundColor: .hex999999), message: dataResponse.dataParameters["buildUpdateDescription"].toStringValue.getAttributedString(font: .size14, foregroundColor: .hex999999).append(lineSpacing: 8), buttonTitles: buttonTitles, buttonBackgroundImages: buttonBackgroundImages, tap: { offset in
                isShow = false
                if offset == 1 {
                    let buildKey = dataResponse.dataParameters["buildKey"].toStringValue
                    guard let url = URL(string: "itms-services://?action=download-manifest&url=https://www.pgyer.com/app/plist/\(buildKey)") else { return }
                    if UIApplication.shared.openURL(url) {
                        exit(EXIT_SUCCESS);
                    }
                } else {
                    UserDefaults.standard.set(buildBundle, forKey: ignoreBuildKey)
                    UserDefaults.standard.synchronize()
                }
            })
            isShow = true
        }
    }
    
}

public extension EasyCheck {
    
    static func configPgyerBeta(api_key: String , shortcutUrl: String, headerImage: UIImage? = nil, delay: TimeInterval = 3, isWillEnterForegroundCheck: Bool = true) {
        EasyApp.runInMain(delay: delay) {
            requestPgyerBeta(api_key: api_key, shortcutUrl: shortcutUrl, headerImage: headerImage)
        }
        if isWillEnterForegroundCheck {
            NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { (_) in
                requestPgyerBeta(api_key: api_key, shortcutUrl: shortcutUrl, headerImage: headerImage)
            }
        }
    }
    
}

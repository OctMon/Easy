//
//  EasyCheck.swift
//  Easy
//
//  Created by OctMon on 2018/10/13.
//

import Foundation

public struct EasyCheck {
    
    private static var isShow: Bool = false
    private static let ignoreBuildKey = "easyIgnoreBuildKey".md5
    
    private static let session: EasySession = {
        var config = EasySessionConfig()
        config.url.global = "http://www.pgyer.com"
        return EasySession(config)
    }()
    
    private init() {}
    
    static func requestPgyerBeta(api_key: String, shortcutUrl: String) {
        guard !isShow else { return }
        session.post(path: "apiv2/app/getByShortcut", isURLEncoding: true, parameters: ["_api_key": api_key, "buildShortcutUrl": shortcutUrl]) { (response) in
            guard response.valid else { return }
            let buildVersionNo = response.data["buildVersionNo"].toIntValue
            let buildBundle = EasyApp.bundleBuild.toIntValue
            guard buildVersionNo > buildBundle else { return }
            let ignoreBuild = UserDefaults.standard.integer(forKey: ignoreBuildKey)
            guard buildBundle != ignoreBuild else { return }
            EasyAlert(title: "有新的beta版[\(buildVersionNo)]", message: response.data["buildUpdateDescription"].toStringValue).addAction(title: "更新", style: .default, preferredAction: true, handler: { (_) in
                let buildKey = response.data["buildKey"].toStringValue
                guard let url = URL(string: "itms-services://?action=download-manifest&url=https://www.pgyer.com/app/plist/\(buildKey)") else { return }
                if UIApplication.shared.openURL(url) {
                    exit(EXIT_SUCCESS);
                }
                isShow = false
            }).addAction(title: "跳过", style: .default, handler: { (_) in
                isShow = false
                UserDefaults.standard.set(buildBundle, forKey: ignoreBuildKey)
                UserDefaults.standard.synchronize()
            }).addAction(title: "以后再说", style: .default, handler: { (_) in
                isShow = false
            }).show()
            isShow = true
        }
    }
    
}

public extension EasyCheck {
    
    static func configPgyerBeta(api_key: String , shortcutUrl: String, delay: TimeInterval = 3, isWillEnterForegroundCheck: Bool = true) {
        EasyApp.runInMain(delay: delay) {
            requestPgyerBeta(api_key: api_key, shortcutUrl: shortcutUrl)
        }
        if isWillEnterForegroundCheck {
            NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { (_) in
                requestPgyerBeta(api_key: api_key, shortcutUrl: shortcutUrl)
            }
        }
    }
    
}

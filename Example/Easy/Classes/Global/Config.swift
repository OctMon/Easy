//
//  Config.swift
//  Easy
//
//  Created by OctMon on 2018/10/14.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

extension AppDelegate {
    
    func config(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        global.backBarButtonItemTitle = ""
        app.openFullScreenPopGesture()
        app.configTest()
        app.configCheckPgyer(api_key: "#replace your api_key", shortcutUrl: "")
        configSocial()
    }

}

private extension AppDelegate {
    
    func configSocial() {
        easy.social.register(weChatAppId: "wx4868b35061f87885", weChatAppKey: "64020361b8ec4c99936c0e3999a9f249")
        easy.social.register(qqAppId: "1104881792")
        easy.social.register(weiboAppId: "1772193724", appKey: "453283216b8c885dad2cdb430c74f62a", redirectURL: "http://sns.whalecloud.com/sina2/callback")
        easy.social.setSharePlatforms([easy.social.SharePlatform(type: .wechat), easy.social.SharePlatform(type: .wechatTimeline), easy.social.SharePlatform(type: .wechatFavorite), easy.social.SharePlatform(type: .qq), easy.social.SharePlatform(type: .qqZone), easy.social.SharePlatform(type: .weibo)])
    }
    
}

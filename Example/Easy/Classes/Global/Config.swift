//
//  Config.swift
//  Easy
//
//  Created by OctMon on 2018/10/14.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

extension AppDelegate {
    
    func configTheme() {
        app.openFullScreenPopGesture()
        global.backBarButtonItemTitle = ""
        global.navigationBarBackgroundImage = UIColor.white.toImage
        global.navigationBarTintColor = UIColor.black
        global.navigationBarTitleTextAttributes = [.foregroundColor: UIColor.black]
        easy.Global.tint = UIColor.hex(0xFF0000)
    }
    
}

extension AppDelegate {
    
    func config(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        app.configTest()
//        app.configCheckPgyer(api_key: "#replace your api_key", shortcutUrl: "")
        configSocial()
        configRouter()
    }

}

private extension AppDelegate {
    
    func configSocial() {
        easy.Social.register(weChatAppId: "wx4868b35061f87885", weChatAppKey: "64020361b8ec4c99936c0e3999a9f249")
        easy.Social.register(qqAppId: "1104881792")
        easy.Social.register(weiboAppId: "1772193724", appKey: "453283216b8c885dad2cdb430c74f62a", redirectURL: "http://sns.whalecloud.com/sina2/callback")
        easy.Social.register(alipayAppId: "2016012101112529")
        
        easy.Social.isFilterPlatformsItems = false
        easy.Social.isShowCancelButton = false
        easy.Social.shareButtonHeight = 70
        easy.Social.shareButtonSpace = 8
        easy.Social.shareImageLess = 30
        easy.Social.setSharePlatforms([
            .init(type: .wechat),
            .init(type: .wechatTimeline),
            .init(type: .wechatFavorite),
            .init(type: .qq),
            .init(type: .qqZone),
            .init(type: .weibo),
            .init(type: .alipayFirends),
            .init(type: .alipayTimeline)
            ]
        )
    }
    
}

private extension AppDelegate {
    
    func configRouter() {
        easy.Router.registerURL("easy://") { (parameters) in
            log.debug(parameters)
            let package = app.bundleExecutable + "."
            guard let name = parameters[.className] as? String else { return }
            guard let vc = NSClassFromString(package + name) as? easy.BaseViewController.Type else { return }
            app.currentViewController?.pushWithHidesBottomBar(to: vc.init())
        }
    }
    
}

//
//  Config.swift
//  Easy
//
//  Created by OctMon on 2018/10/14.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

extension AppDelegate {
    
    func configGlobal() {
        app.openFullScreenPopGesture()
        easy.WebImage.isPrintWebImageUrl = true
        global.backBarButtonItemTitle = ""
        global.backBarButtonItemImage = #imageLiteral(resourceName: "icon_currentPageIndicatorImage")
        global.navigationBarBackgroundImage = UIColor.white.toImage
        global.navigationBarIsShadowNull = true
        global.navigationBarTintColor = UIColor.black
        global.navigationBarTitleTextAttributes = [.foregroundColor: UIColor.black]
        global.tint = .hex(0xFF0000)
        global.loadingText = "EasyGlobal.loadingText"
    }
    
}

extension AppDelegate {
    
    func config(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        app.configTestTool()
//        app.configCheckPgyer(api_key: "#replace your api_key", shortcutUrl: "")
        configSocial()
        configRouter()
    }

}

private extension AppDelegate {
    
    func configSocial() {
        easy.Social.register(weChatAppId: "wx4868b35061f87885", weChatAppKey: "64020361b8ec4c99936c0e3999a9f249", miniAppID: "gh_d43f693ca31f")
        easy.Social.register(qqAppId: "1104881792")
        easy.Social.register(weiboAppId: "1772193724", appKey: "453283216b8c885dad2cdb430c74f62a", redirectURL: "http://sns.whalecloud.com/sina2/callback")
        easy.Social.register(alipayAppId: "2016012101112529")
        
        if app.isDebug {
            easy.Social.isFilterPlatformsItems = false
        }
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
            guard let vcType = NSClassFromString(package + name) as? UIViewController.Type else { return }
            let vc = vcType.init()
            if let title = (parameters[.userInfo] as? easy.Parameters)?["title"] as? String {
                vc.navigationItem.title = title
            }
            app.currentViewController?.pushWithHidesBottomBar(to: vc)
        }
    }
    
}

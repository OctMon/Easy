//
//  AppDelegate.swift
//  Easy
//
//  Created by octmon on 10/07/2018.
//  Copyright (c) 2018 octmon. All rights reserved.
//

import UIKit
import Easy

typealias easy = Easy
typealias app = easy.App
typealias log = easy.Log
typealias alert = easy.Alert
typealias actionSheet = easy.ActionSheet
typealias global = easy.Global
typealias router = easy.Router

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configGlobal()
        window = easy.NavigationController(rootViewController: Main()).makeRootViewController()
        config(application, launchOptions: launchOptions)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return easy.Social.handleOpenURLSocial(open: url)
    }


}


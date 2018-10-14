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
typealias app = EasyApp
typealias log = EasyLog
typealias alert = EasyAlert
typealias actionSheet = EasyActionSheet
typealias global = EasyGlobal
typealias router = EasyRouter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = easy.BaseNavigationController(rootViewController: Main()).makeRootViewController()
        config(application, launchOptions: launchOptions)
        return true
    }


}


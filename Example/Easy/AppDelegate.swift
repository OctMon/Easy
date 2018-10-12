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
typealias log = easy.log
typealias app = easy.app
typealias global = easy.global

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = Main().makeRootViewController()
        return true
    }


}


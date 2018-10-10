//
//  Main.swift
//  Easy_Example
//
//  Created by OctMon on 2018/10/7.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class Main: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.globalBackground
        easy.app.runInMain(delay: 1) {
            easy.social.share(title: "abc", description: "def", thumbnail: nil, url: "hhh")
        }
    }
    
}

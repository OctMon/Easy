//
//  PageViewController.swift
//  Easy
//
//  Created by OctMon on 2018/10/27.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class PageViewController: easy.Page {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "EasyPage"
    }
    
    override func configure() {
        super.configure()
        
        defer {
            setPage(titles: ["Social", "Tuchong"]) { (index) -> UIViewController in
                switch index {
                case 0:
                    return SocialViewController()
                case 1:
                    return TuchongViewController()
                default:
                    return easy.ViewController()
                }
            }
        }
    }

}

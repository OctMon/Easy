//
//  PagingViewController.swift
//  Easy
//
//  Created by OctMon on 2018/10/27.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class PagingViewController: easy.BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "PagingKit"
        
        setPaging(dataSource: ["Martinez", "Alfred", "Louis", "Justin", "Tim", "Deborah", "Michael", "Choi", "Hamilton", "Decker", "Johnson", "George"].enumerated().map {
            let title = $0.element
            let viewController = easy.BaseViewController()
            viewController.view.showPlaceholder(attributedString: ($0.element + "\n" + $0.offset.toString).getAttributedString)
            return (menu: title, content: viewController)
        })
    }

}
